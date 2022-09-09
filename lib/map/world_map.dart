import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    var json = await worldMapData.getJson(context);
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
        playerPath: PlayerPath(playerPosition: PlayerPosition(tileAPosition: Vector2(33.0, 15.0), amountTravelled: 0)),
        initialStartingOffset: 0.0,
      );
    }


    player.priority = 99999;
    await add(player);

    //Camera Controller
    cameraController = CameraController(camera: camera);
    await add(cameraController);

    cameraController.position = player.sprite.absolutePosition;
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
    cameraController.fly(player.sprite.absolutePosition);
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
      pos += mapCoordinate;
      topLeft = topLeft == null ? pos : Vector2(min(topLeft.x, pos.x), min(topLeft.y, pos.y));
      bottomRight = bottomRight == null ? pos : Vector2(max(bottomRight.x, pos.x), max(bottomRight.y, pos.y));
    }
    if(topLeft != null && bottomRight != null){
      var size = bottomRight - topLeft;
      var zoom = min(
        size.x/camera.viewport.effectiveSize.x,
        size.y/camera.viewport.effectiveSize.y,
      );
      pos /= mapCoordinates.length.toDouble();
      cameraController.fly(pos, targetZoom: zoom);
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

  set onCoordinatesReached(Function(Vector2) n){
    player.onCoordinatesReached = n;
  }

  set highlightedQuestLocations(List<Vector2> n){
    for(var locationCoordinates in _highlightedQuestLocations){
      hexTileMap?.getTileFromVector2(locationCoordinates)?.removeSelector(HexTileSelectorType.questView);
    }
    _highlightedQuestLocations = n;
    for(var locationCoordinates in _highlightedQuestLocations){
      hexTileMap?.getTileFromVector2(locationCoordinates)?.addSelector((_, __) {}, HexTileSelectorType.questView);
    }
  }

  set onMapDrag(Function n) => cameraController.onCameraChangePosition = n;

  void savePlayer(){
    final saveHandler = locator.get<SaveDataHandler>();
    saveHandler.updateMap(["game", "map", "player"], player.toJson(), override: true);
    saveHandler.saveData();
  }





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