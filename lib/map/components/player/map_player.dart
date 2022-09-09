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
  late SvgComponent sprite;
  late PlayerRouteBuilder playerRouteBuilder;
  late PlayerPathLine playerPathLine;
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
    var svg = await Svg.load("images/world_map/player/player2.svg");
    sprite = SvgComponent(svg: svg)
      ..size = Vector2(200, 200)
      ..anchor = Anchor.center;
    add(sprite);
    add(playerRouteBuilder);
    playerPathLine = PlayerPathLine(path: [...playerPath.path], hexTileMap: hexTileMap);
    add(playerPathLine);

    playerPathSubscription = playerPath.stream.listen(
      (newPlayerPath) {
        if(inBuildingMode){
          playerRouteBuilder.updatePossibleExtensions(hexTileMap);
        }
        playerPathLine.updatePath(playerPath.path);
      }
    );

    sprite.position = playerPath.playerPosition?.getRealPosition(hexTileMap) ?? Vector2.zero();

    playerPathLine.endPercentageHidden = startingOffset;
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
    playerPathLine.updatePlayerDistance(_amountTravelled/hexDistance+startingOffset);
    if(playerPath.playerPosition?.getRealPosition(hexTileMap) != null){
      sprite.position = playerPath.playerPosition?.getRealPosition(hexTileMap)! ?? Vector2.zero();
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
    playerPathLine.endPercentageHidden = _startingOffset;
  }

  double get startingOffset => _startingOffset;

  double get pathLength => (playerPath.path.length.toDouble()-1-startingOffset)*hexDistance;

  set onCoordinatesReached(Function(Vector2 coordinates) n) => playerPath.playerPosition?.onCoordinatesReached = n;
}