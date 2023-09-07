import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:running_game/json_converters/json_loader.dart';
import 'package:running_game/pages/map_page/view_model.dart';
import 'package:running_game/saving_service/saving_service.dart';

import '../locator.dart';
import 'components/camera_controller.dart';
import 'components/hex_tile/hex_tile.dart';
import 'components/hex_tile/hex_tile_selector.dart';
import 'components/hex_tile_map.dart';
import 'components/map_layer.dart';
import 'components/player/map_player.dart';
import 'components/player/player_path.dart';
import 'components/player/player_position.dart';
import 'map_data_service.dart';




class WorldMapGame extends FlameGame with ScaleDetector, HasTappables {

  final BuildContext context;
  MapPageViewModel viewModel;
  late final List<List<HexTile>> tiles;
  var _inBuildingMode = false;
  var _highlightedQuestLocations = <Vector2>[];
  var _questMarkerQuestIds = <Vector2, List<int>>{};
  late MapPlayer player;
  late CameraController cameraController;
  HexTileMap? hexTileMap;
  MapLayer? mapLayer;

  WorldMapGame({required this.context, required this.viewModel});

  @override
  void render(Canvas canvas) {
    mapLayer?.render(canvas);
    super.render(canvas);
  }

  @override
  Color backgroundColor() => const Color(0xff36C5F4);

  @override
  Future<void>? onLoad() async {


    //World and Map

    var worldMapData = WorldMapData();
    var json = await JsonLoader().getJson(context, "assets/data/world_map.json");
    hexTileMap = worldMapData.generateGroundFromJson(json["ground"]);

    for(var column in hexTileMap!.tiles){
      for(var tile in column){
        await add(tile);
      }
    }



    //Player
    final saveHandler = locator.get<SaveDataHandler>();
    Map<String, dynamic>? playerData = saveHandler.findMap(["game", "map", "player"]);
    if(playerData != null){
      player = MapPlayer.fromJson(playerData, hexTileMap!);
    } else {
      player = MapPlayer(
        hexTileMap: hexTileMap!,
        playerPath: PlayerPath(playerPosition: PlayerPosition(tileAPosition: Vector2(21.0, 10.0), amountTravelled: 0)),
        initialStartingOffset: 0.0,
      );
    }


    player.priority = 99999;
    await add(player);

    //Camera Controller
    cameraController = CameraController(camera: camera);
    await add(cameraController);
    cameraController.position = hexTileMap?.getTileFromVector2(player.playerPath.path.first)?.hexTop.absolutePosition;
    cameraController.zoom = 1/5;
    onStructurePressed = ((_, __) {});
    viewModel.onMapLoaded();
    return super.onLoad();
  }

  @override
  void onScaleStart(_) {
    cameraController.scaleStartZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      cameraController.zoom = cameraController.scaleStartZoom * (currentScale.x+currentScale.y)/2;
    } else {
      cameraController.controlPosition(cameraController.position-info.delta.game);
      cameraController.camera.snap();
    }


  }

  void updateViewportSize(Size size){
    camera.viewport = FixedResolutionViewport(Vector2(size.width, size.height));
    print("New Viewport Size: ${size.width}, ${size.height}");
  }


  set inBuildingMode(n){
    if(_inBuildingMode != n){
      _inBuildingMode = n;
      if(_inBuildingMode){
        player.enterBuildingMode();
      } else {
        player.exitBuildingMode();
      }
    }
  }

  void flyCameraToPlayer(){
    cameraController.fly(player.sprite?.absolutePosition ?? Vector2.zero());
  }


  void flyCameraToTargetLocation(){
    var pos = hexTileMap?.getTileFromVector2(player.playerPath.path.last)?.hexTop.absolutePosition;
    if(pos != null){cameraController.fly(pos);}
  }

  void flyCameraToCenterOf(List<Vector2> mapCoordinates){
    var pos = Vector2.zero();
    Vector2? topLeft;
    Vector2? bottomRight;
    for(var mapCoordinate in mapCoordinates){
      pos = hexTileMap?.getTileFromVector2(mapCoordinate)?.hexTop.absolutePosition ?? Vector2.zero();
      topLeft = topLeft == null ? pos : Vector2(min(topLeft.x, pos.x), min(topLeft.y, pos.y));
      bottomRight = bottomRight == null ? pos : Vector2(max(bottomRight.x, pos.x), max(bottomRight.y, pos.y));
    }

    if(topLeft != null && bottomRight != null){
      var size = (bottomRight - topLeft);
      var zoom = 0.2;
      if(size.x != 0 && size.y != 0){
        zoom = min(
          min(
            camera.viewport.effectiveSize.x/size.x/1.5,
            camera.viewport.effectiveSize.y/size.y/1.5,
          ),
          0.2
        );
      } else if (size.x != 0){
        zoom = size.x;
      } else if (size.y != 0){
        zoom = size.y;
      }

      cameraController.fly((topLeft+bottomRight)/2, targetZoom: zoom);

    }
  }

  void deletePathSegment(){
    player.playerPath.reduce();
  }

  double get pathLength {
    return player.pathLength;
  }

  String? get targetLocationName {
    return hexTileMap?.getTileFromVector2(player.playerPath.path.last)?.structure?.name;
  }

  set distanceTravelled(double n){
    player.amountTravelled = n;
  }

  void solidifyPlayerPath(){
    player.solidifyPath();
  }

  set onStructurePressed(Function(TapUpInfo, HexTileSelector) n){
    if(hexTileMap != null){
      for(var column in hexTileMap!.tiles){
        for(var tile in column){
          tile.onStructurePressed = (tapUpInfo, hexTileSelector) {cameraController.fly(tile.absolutePosition); n(tapUpInfo, hexTileSelector);};
        }
      }
    }
  }

  set onCoordinatesReached(Function(Vector2, HexTileMap) n){
    player.onCoordinatesReached = n;
  }

  set highlightedQuestLocations(List<Vector2> n){
    for(var locationCoordinates in _highlightedQuestLocations){
      hexTileMap?.getTileFromVector2(locationCoordinates)?.removeSelector(HexTileSelectorType.questView);
    }
    _highlightedQuestLocations = n;
    for(var locationCoordinates in _highlightedQuestLocations){
      hexTileMap?.getTileFromVector2(locationCoordinates)?.addSelector(null, HexTileSelectorType.questView);
    }
  }

  set onMapDrag(Function n) => cameraController.onCameraDrag = n;

  set questMarkerQuestIds(Map<Vector2, List<int>> n){

    _questMarkerQuestIds.forEach((mapCoordinates, updates) {
      for(var localQuestId in updates){
        hexTileMap?.getTileFromVector2(mapCoordinates)?.removeQuestMarker(localQuestId);
      }
    });

    _questMarkerQuestIds = n;

    _questMarkerQuestIds.forEach((mapCoordinates, updates) {
      for(var localQuestId in updates){
        hexTileMap?.getTileFromVector2(mapCoordinates)?.addQuestMarker(localQuestId);
        if(!updates.contains(localQuestId)){
          hexTileMap?.getTileFromVector2(mapCoordinates)?.removeQuestMarker(localQuestId);
        }
      }
    });
  }

  void savePlayer(){
    final saveHandler = locator.get<SaveDataHandler>();
    saveHandler.updateMap(["game", "map", "player"], player.toJson(), override: true);
    saveHandler.saveData();
  }

  set playerSkin(int n) => player.playerSkin = n;




  /*
  var dragPointers = <int, Vector2> {};

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    if(dragPointers.keys.length < 2){
      dragPointers[pointerId] = info.eventPosition.viewport;
    }
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    print("test2");
    if(dragPointers.containsKey(pointerId) && dragPointers.keys.length == 2){
      print("test");
      var allKeys = dragPointers.keys as List<int>;
      allKeys.remove(pointerId);
      var otherPointerId = allKeys[0];
      camera.zoom *= info.eventPosition.viewport.distanceTo(dragPointers[otherPointerId]!) / dragPointers[pointerId]!.distanceTo(dragPointers[otherPointerId]!);
    }
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    if(dragPointers.containsKey(pointerId)){
      dragPointers.remove(pointerId);
    }
  }

   */


}