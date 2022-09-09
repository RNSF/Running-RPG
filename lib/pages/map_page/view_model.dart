import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_quest_marker.dart';
import 'package:running_game/map/components/hex_tile/structures/hex_tile_structure.dart';
import 'package:running_game/pages/quest_page/models/quest_handler_model.dart';
import 'package:running_game/pages/quest_page/view_model.dart';
import '../../locator.dart';
import '../../map/world_map.dart';
import '../quest_page/models/quest.dart';

enum MapState{
  standard,
  building,
  recording,
  structureView,
  questView,
  loading,
}

class MapPageViewModel with ChangeNotifier{
  final questHandler = locator.get<QuestHandlerModel>();

  var _mapState = MapState.loading;
  var _routeLength = 1.0;
  var _distanceTravelled = 0.0;
  var _currentQuests = <int, Quest>{};
  var selectedStructureName = "";
  var selectedStructureDescription = "";
  var selectedStructureQuestMarkers = <HexTileQuestMarker> [];
  late StreamSubscription questHandlerSubscription;
  WorldMapGame? gameMap;


  MapPageViewModel({required BuildContext context}) {
    generateWorldMap(context);

    questHandlerSubscription = questHandler.stream.listen(
      onQuestHandlerUpdate
    );
  }

  double get distanceTravelled => _distanceTravelled;

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
    if(oldMapState != _mapState){
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
      }
      switch(_mapState){
        case MapState.building:
          gameMap?.inBuildingMode = true;
          gameMap?.flyCameraToTargetLocation();
          break;
        case MapState.recording:
          gameMap?.flyCameraToPlayer();
          gameMap?.onCoordinatesReached = onCoordinatesReached;
          break;
        case MapState.standard:
          gameMap?.onStructurePressed = ((_, hexTileSelector) {
            var structure = gameMap?.hexTileMap?.getTileFromVector2(hexTileSelector.tilePosition)?.structure;
            if(structure != null){onStructureSelected(structure);}
          });
          gameMap?.onMapDrag = onMapDrag;
          break;
        case MapState.questView:
          var locationCoordinates = <Vector2>[];
          var destinations = questHandler.currentlyViewedQuest?.destinations ?? [];
          for(var destination in destinations){
            locationCoordinates.add(destination.mapCoordinates ?? Vector2.zero());
          }
          gameMap?.flyCameraToCenterOf(locationCoordinates);
          gameMap?.highlightedQuestLocations = locationCoordinates;
          break;
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
    mapState = MapState.standard;
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

  void onMapLoaded() {
    mapState = MapState.standard;
  }

  void onGameMapSizeChange(Size size){
    gameMap?.updateViewportSize(size);
  }

  void travel(distance){
    distanceTravelled += distance;
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
    if(mapState == MapState.structureView){
      mapState = MapState.standard;
    }
  }

  set currentQuests(Map<int, Quest> n){
    _currentQuests = n;
    notifyListeners();
  }

  Map<int, Quest> get currentQuests => _currentQuests;

  void onCoordinatesReached(Vector2 mapCoordinates){
    questHandler.onCoordinatesReached(mapCoordinates);
  }

  void onQuestHandlerUpdate(QuestHandlerModel _){
    if(questHandler.currentlyViewedQuest != null){
      mapState = MapState.questView;
    }
    if(currentQuests != questHandler.activeQuests){
      currentQuests = questHandler.activeQuests;
    }
  }

  @override
  void dispose() {
    //questHandlerSubscription.cancel();
    super.dispose();
  }
}