import 'dart:math';

import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/json_converters/vector2_json_converter.dart';
import 'package:running_game/map/components/player/player_path.dart';

import '../../../pages/map_page/travel_event.dart';
import '../hex_tile/hex_tile.dart';
import '../hex_tile_map.dart';


class PlayerPosition {
  @Vector2JsonConverter()
  late Vector2 _tileAPosition;
  @Vector2JsonConverter()
  Vector2? tileBPosition;
  double amountTravelled;
  bool isPointingLeft;
  Function(Vector2 coordinates)? _onCoordinatesReached;

  PlayerPosition({Vector2? tileAPosition, this.tileBPosition, this.amountTravelled = 0.0, this.isPointingLeft = false}) {
    _tileAPosition = tileAPosition ?? Vector2(21.0, 10.0);
  }

  factory PlayerPosition.fromJson(Map json) => PlayerPosition(tileAPosition: Vector2.zero(), amountTravelled: 0);
  Map<String, dynamic> toJson() => {};

  Vector2? getRealPosition(HexTileMap hexTileMap) {
    HexTile? tileA = hexTileMap.getTileFromVector2(tileAPosition);
    if(tileBPosition != null){
      HexTile? tileB = hexTileMap.getTileFromVector2(tileBPosition!);
      if(tileA != null && tileB != null){
        return tileA.hexTop.absolutePosition + (tileB.hexTop.absolutePosition - tileA.hexTop.absolutePosition).scaled(amountTravelled);
      }
    } else if(tileA != null) {
      return tileA.hexTop.absolutePosition;
    }
  }


  void update(PlayerPath playerPath, double distanceTravelled){
    var oldAmountTravelled = amountTravelled;
    distanceTravelled = min(distanceTravelled, (playerPath.length));
    amountTravelled = distanceTravelled % 1.0;
    distanceTravelled -= amountTravelled;
    var index = (distanceTravelled).round();
    tileAPosition = playerPath.path[index];
    tileBPosition = playerPath.path.length > index+1 ? playerPath.path[index+1] : null;
    isPointingLeft = (tileBPosition == null || tileAPosition.x == tileBPosition?.x) ? isPointingLeft : (tileAPosition.x > tileBPosition!.x);
    print("IS POINTING LEFT? $isPointingLeft");
  }

  @Vector2JsonConverter()
  Vector2 get tileAPosition => _tileAPosition;

  set tileAPosition(Vector2 n) {
    if(_tileAPosition != n){
      _tileAPosition = n;
      if(onCoordinatesReached != null){
        onCoordinatesReached!(tileAPosition);
      }
    }
  }

  get onCoordinatesReached => _onCoordinatesReached;
  set onCoordinatesReached(n) {
    _onCoordinatesReached = n;
    onCoordinatesReached(tileAPosition);
    print("On coordinates reached set!");
  }
}