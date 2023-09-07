import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/json_converters/vector2_json_converter.dart';
import 'package:running_game/map/components/hex_tile_map.dart';
import 'package:running_game/map/components/player/player_position.dart';

part "player_path.g.dart";

@JsonSerializable()
class PlayerPath {
  @Vector2JsonConverter()
  List<Vector2> path = [];
  PlayerPosition? playerPosition;
  final _controller = StreamController<PlayerPath>();

  PlayerPath({List<Vector2> startingPath = const [], this.playerPosition}){
    playerPosition = playerPosition ?? PlayerPosition();
    if(startingPath.isEmpty){
      updatePath([playerPosition?.tileAPosition ?? Vector2.zero()]);
    } else {
      updatePath(startingPath);
    }
  }

  factory PlayerPath.fromJson(Map json) => _$PlayerPathFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerPathToJson(this);

  Stream<PlayerPath> get stream =>
      _controller.stream;

  void updatePath(List<Vector2> newPath){
    path = newPath;
    _controller.sink.add(this);
  }

  void add(Vector2 addition){
    path.add(addition);
    updatePath(path);
  }

  void reduce(){
    if(path.length > 2 || (path.length > 1 && playerPosition?.tileBPosition == null)){
      path.removeLast();
      updatePath(path);
    }
  }

  void chop(){
    path.removeAt(0);
    updatePath(path);
  }

  double get length {
    return (path.length-1)*1.0;
  }
}