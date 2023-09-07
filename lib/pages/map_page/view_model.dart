import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_quest_marker.dart';
import 'package:running_game/map/components/hex_tile/structures/hex_tile_structure.dart';
import 'package:running_game/pages/map_page/travel_event.dart';
import 'package:running_game/pages/navigation_master_page/remote_controller_model.dart';
import 'package:running_game/pages/quest_page/models/quest_handler_model.dart';
import 'package:running_game/pages/quest_page/view_model.dart';
import '../../locator.dart';
import '../../map/components/hex_tile_map.dart';
import '../../map/world_map.dart';
import '../character_page/models/player_handler_model.dart';
import '../quest_page/models/quest.dart';

enum MapState{
  standard,
  building,
  recording,
  structureView,
  questView,
  eventOverview,
  loading,
}

class MapPageViewModel with ChangeNotifier{
  final questHandler = locator.get<QuestHandlerModel>();
  final remoteNavigationController = locator.get<RemoteNavigationControllerModel>();
  final playerHandler = locator.get<PlayerHandlerModel>();

  var _mapState = MapState.loading;
  var _routeLength = 1.0;
  var _distanceTravelled = 0.0;
  var _currentQuests = <int, Quest>{};
  var selectedStructureName = "";
  var selectedStructureDescription = "";
  var selectedStructureQuestMarkers = <HexTileQuestMarker> [];
  var forceUpdateState = false;
  var travelEventIndex = 0;
  late StreamSubscription questHandlerSubscription;
  WorldMapGame? gameMap;


  MapPageViewModel({required BuildContext context}) {
    playerHandler.addListener(onPlayerHandlerUpdate);
    generateWorldMap(context);
    questHandlerSubscription = questHandler.stream.listen(
      onQuestHandlerUpdate
    );
  }

  List<TravelEvent> get pendingTravelEvents => questHandler.pendingTravelEvents;
  set pendingTravelEvents(n) => questHandler.pendingTravelEvents = n;

  double get distanceTravelled => _distanceTravelled;

  TravelEvent? get currentEvent => pendingTravelEvents.length > travelEventIndex ? pendingTravelEvents[travelEventIndex] : null;

  bool get isLastEvent => pendingTravelEvents.length - 1 == travelEventIndex;

  set distanceTravelled(n){
    _distanceTravelled = n;
    _distanceTravelled = min(_routeLength,_distanceTravelled);
    gameMap?.distanceTravelled = _distanceTravelled;
    notifyListeners();
  }

  double get routeLength => _routeLength;

  double get routeProgress => routeLength == 0 ? 0.0 : distanceTravelled/routeLength;

  double get cleanRouteLength => (routeLength*10).round()/10;
  double get cleanDistanceTravelled => (distanceTravelled*10).round()/10;


  get mapState => _mapState;

  set mapState(n){
    var oldMapState = _mapState;
    _mapState = n;
    if(oldMapState != _mapState || forceUpdateState){
      switch(oldMapState){
        case MapState.building:
          gameMap?.inBuildingMode = false;
          _routeLength = gameMap?.pathLength ?? 1.0;
          gameMap?.savePlayer();
          break;
        case MapState.recording:
          gameMap?.solidifyPlayerPath();
          distanceTravelled = 0.0;
          _routeLength = gameMap?.pathLength ?? 1.0;
          gameMap?.savePlayer();
          break;
        case MapState.standard:
          gameMap?.onStructurePressed = ((_, __) {});
          gameMap?.onMapDrag = () {};
          break;
        case MapState.questView:
          gameMap?.highlightedQuestLocations = [];
          break;
        case MapState.loading:
          distanceTravelled = 0.0;
          _routeLength = gameMap?.pathLength ?? 1.0;
          break;
        case MapState.eventOverview:
          questHandler.pendingTravelEvents = [];

      }
      switch(_mapState){
        case MapState.eventOverview:
          travelEventIndex = 0;
          if(pendingTravelEvents.isEmpty){
            mapState = MapState.standard;
          }
          break;

        case MapState.building:
          gameMap?.inBuildingMode = true;
          gameMap?.flyCameraToTargetLocation();
          break;
        case MapState.recording:
          gameMap?.flyCameraToPlayer();
          break;
        case MapState.standard:
          questHandler.currentlyViewedQuest = null;
          gameMap?.onStructurePressed = ((_, hexTileSelector) {
            var structure = gameMap?.hexTileMap?.getTileFromVector2(hexTileSelector.tilePosition)?.structure;
            if(structure != null){onStructureSelected(structure);}
          });
          break;
        case MapState.questView:
          gameMap?.onMapDrag = onMapDrag;
          var locationCoordinates = <Vector2>[];
          var destinations = questHandler.currentlyViewedQuest?.questMarkerLocation ?? [];
          for(var destination in destinations){
            locationCoordinates.add(destination.mapCoordinates ?? Vector2.zero());
          }
          gameMap?.flyCameraToCenterOf(locationCoordinates);
          gameMap?.highlightedQuestLocations = locationCoordinates;
          break;
        case MapState.structureView:
          gameMap?.onMapDrag = onMapDrag;
      }
    }
    notifyListeners();
  }

  String get targetLocationName {
    return gameMap?.targetLocationName ?? "Nameless Location";
  }

  void generateWorldMap(BuildContext context) {
    gameMap = WorldMapGame(context: context, viewModel: this);
  }

  void onFinishRecordButtonPressed() {
    mapState = MapState.eventOverview;
  }

  void onEditRouteButtonPressed() {
    mapState = MapState.building;
    return;
  }

  void onRecordButtonPressed() {
    mapState = MapState.recording;
    return;
  }

  void onDeletePathSegmentButtonPressed() {
    gameMap?.deletePathSegment();
    return;
  }

  void onFinishEditRouteButtonPressed() {
    mapState = MapState.standard;
    return;
  }

  void onQuestTapped(int localQuestId) {
    remoteNavigationController.queueSwitch("Location");
  }

  void onMapLoaded() {
    currentQuests = <int, Quest>{... questHandler.activeQuests};
    gameMap?.onCoordinatesReached = onCoordinatesReached;
    if(questHandler.currentlyViewedQuest != null){
      mapState = MapState.questView;
    } else {
      mapState = MapState.standard;
    }
  }

  void onGameMapSizeChange(Size size){
    gameMap?.updateViewportSize(size);
  }

  void travel(distance){
    distanceTravelled += distance;
    gameMap?.flyCameraToPlayer();
  }

  void onStructureSelected(HexTileStructure structure){
    selectedStructureName = structure.name;
    selectedStructureDescription = structure.description;
    selectedStructureQuestMarkers = gameMap?.hexTileMap?.getTileFromVector2(structure.mapCoordinates)?.questMarkers ?? [];
    if(mapState == MapState.standard){
      mapState = MapState.structureView;
    }
  }

  void onMapDrag(){
    if(mapState == MapState.structureView || mapState == MapState.questView){
      mapState = MapState.standard;
    }
  }

  set currentQuests(Map<int, Quest> n){
    _currentQuests = n;
    updateQuestMarkers(currentQuests);
    notifyListeners();
  }

  Map<int, Quest> get currentQuests => _currentQuests;

  void onCoordinatesReached(Vector2 mapCoordinates, HexTileMap hexTileMap){
    questHandler.onCoordinatesReached(mapCoordinates, hexTileMap);
  }

  void onQuestHandlerUpdate(QuestHandlerModel _){
    if(currentQuests.length != questHandler.activeQuests.length){
      currentQuests = <int, Quest>{... questHandler.activeQuests};
    }
    if(questHandler.currentlyViewedQuest != null){
      forceUpdateState = true;
        mapState = MapState.questView;
      forceUpdateState = false;
    } else {
      if(mapState == MapState.questView){
        mapState = MapState.standard;
      }
    }
    updateQuestMarkers(questHandler.activeQuests);
  }

  void updateQuestMarkers(Map<int, Quest> quests){
    var pendingUpdates = <Vector2, List<int>>{};
    quests.forEach((localQuestId, quest) {
      for(var destination in quest.questMarkerLocation){
        if(pendingUpdates.keys.contains(destination.mapCoordinates)){
          pendingUpdates[destination.mapCoordinates]?.add(localQuestId);
        } else {
          pendingUpdates[destination.mapCoordinates ?? Vector2.zero()] = [localQuestId];
        }
      }
    });
    print(pendingUpdates);
    gameMap?.questMarkerQuestIds = pendingUpdates;
  }

  void onNextEventButtonPressed(){
    travelEventIndex++;
    notifyListeners();
  }

  void onCloseEventButtonPressed(){
    mapState = MapState.standard;
  }

  void onPlayerHandlerUpdate(){
    gameMap?.playerSkin = playerHandler.playerSkin;
  }

  @override
  void dispose() {
    //questHandlerSubscription.cancel();
    super.dispose();
  }
}