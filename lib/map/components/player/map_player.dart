import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/map/components/player/path_line.dart';
import 'package:running_game/map/components/player/player_path.dart';
import 'package:running_game/map/components/player/player_position.dart';
import 'package:running_game/map/components/player/route_builder.dart';

import '../hex_tile_map.dart';

class MapPlayer extends PositionComponent{
  SvgComponent? sprite;
  late PlayerRouteBuilder playerRouteBuilder;
  List<PlayerPathLine> playerPathLines = [];
  late final playerPathSubscription;
  final HexTileMap hexTileMap;
  PlayerPath playerPath;
  bool inBuildingMode = false;
  List<Vector2> currentRoute = [];
  var _amountTravelled = 0.0;
  var _startingOffset = 0.0;
  final hexDistance = 1.0;

  MapPlayer({required this.hexTileMap, required this.playerPath, required double initialStartingOffset}){
     playerRouteBuilder = PlayerRouteBuilder(playerPath: playerPath);
     _startingOffset = initialStartingOffset;
  }

  factory MapPlayer.fromJson(Map<String, dynamic> json, HexTileMap hexTileMap) => MapPlayer(
    hexTileMap: hexTileMap,
    playerPath: PlayerPath.fromJson(json["player_path"]),
    initialStartingOffset: json["starting_offset"] ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "player_path" : playerPath.toJson(),
    "starting_offset" : startingOffset,
  };

  @override
  Future<void>? onLoad() async {

    playerPathLines.add(PlayerPathLine(path: [...playerPath.path], hexTileMap: hexTileMap, isShadow: true));
    playerPathLines.add(PlayerPathLine(path: [...playerPath.path], hexTileMap: hexTileMap));

    playerPathSubscription = playerPath.stream.listen(
      (newPlayerPath) {
        if(inBuildingMode){
          playerRouteBuilder.updatePossibleExtensions(hexTileMap);
        }
        for(var playerPathLine in playerPathLines){
          playerPathLine.updatePath(playerPath.path);
        }
      }
    );

    updateSprite(0);

    add(playerRouteBuilder);

    for(var playerPathLine in playerPathLines){
      add(playerPathLine);
      playerPathLine.endPercentageHidden = startingOffset;
      playerPathLine.priority = -1;
    }
  }

  void updateSprite(int index) async {
    if(sprite != null){
      remove(sprite!);
    }
    var svg = await Svg.load("images/world_map/player/player${(index%4)+1}.svg");
    sprite = SvgComponent(svg: svg)
      ..size = Vector2(200, 200)
      ..anchor = Anchor.center
      ..position = Vector2(0, 100);
    add(sprite!);
    sprite?.position = playerPath.playerPosition?.getRealPosition(hexTileMap) ?? Vector2.zero();
    sprite?.scale = (playerPath.playerPosition?.isPointingLeft ?? false) ? Vector2(-1, 1) : Vector2(1, 1);
    print(playerPath.playerPosition?.getRealPosition(hexTileMap));
  }

  void enterBuildingMode(){
    inBuildingMode = true;
    playerRouteBuilder.updatePossibleExtensions(hexTileMap);
  }

  void exitBuildingMode(){
    inBuildingMode = false;
    playerRouteBuilder.removeAllExtensions(hexTileMap);
  }

  set amountTravelled(n){
    _amountTravelled = min(n, pathLength);
    playerPath.playerPosition?.update(playerPath, _amountTravelled/hexDistance+startingOffset); //remove distance from playerPath playerPosition
    for(var playerPathLine in playerPathLines){
      playerPathLine.updatePlayerDistance(_amountTravelled/hexDistance+startingOffset);
    }
    if(playerPath.playerPosition?.getRealPosition(hexTileMap) != null){
      sprite?.position = playerPath.playerPosition?.getRealPosition(hexTileMap)! ?? Vector2.zero();
      sprite?.scale = (playerPath.playerPosition?.isPointingLeft ?? false) ? Vector2(-1, 1) : Vector2(1, 1);
    }
  }

  void solidifyPath(){
    for(var i = 0; i<(_amountTravelled/hexDistance+startingOffset).floor(); i++){
      playerPath.chop();
    }
    startingOffset = (_amountTravelled/hexDistance+startingOffset) % 1.0;
    amountTravelled = 0.0;
  }

  set startingOffset(n){
    _startingOffset = n;
    for(var playerPathLine in playerPathLines){
      playerPathLine.endPercentageHidden = _startingOffset;
    }
  }

  double get startingOffset => _startingOffset;

  double get pathLength => (playerPath.path.length.toDouble()-1-startingOffset)*hexDistance;

  set onCoordinatesReached(Function(Vector2 coordinates, HexTileMap hexTileMap) n) => playerPath.playerPosition?.onCoordinatesReached = (Vector2 coordinates) => n(coordinates, hexTileMap);

  set playerSkin(int n) => updateSprite(n);
}