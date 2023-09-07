import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../hex_tile_map.dart';

class PlayerPathLine extends Component {
  final HexTileMap hexTileMap;
  bool isShadow;
  List<Vector2> path;
  Map<LineSegment, PathLineSegment> pathSegments = {};
  double _endPercentageHidden = 0.0;

  PlayerPathLine({required this.path, required this.hexTileMap, this.isShadow = false}){
    generatePath(path);
  }

  void generatePath(List<Vector2> path){
    Vector2? previousPoint;
    for(var point in path){
      if(previousPoint != null){
        generatePathSegment(LineSegment(pointA: previousPoint, pointB: point));
      }
      previousPoint = point;
    }
  }

  void generatePathSegment(LineSegment lineSegment){
    if(!pathSegments.keys.contains(lineSegment)){
      var tileA = hexTileMap.getTileFromVector2(lineSegment.pointA);
      var tileB = hexTileMap.getTileFromVector2(lineSegment.pointB);
      if(tileA != null && tileB != null){
        var pathSegment = PathLineSegment(pointA: tileA.hexTop.absolutePosition, pointB: tileB.hexTop.absolutePosition, isShadow: isShadow);
        pathSegments[lineSegment] = pathSegment;
        add(pathSegment);
      }
    }
  }

  void removePathSegment(LineSegment lineSegment){
    if(pathSegments.keys.contains(lineSegment)){
      var pathSegment = pathSegments[lineSegment]!;
      remove(pathSegment);
      pathSegments.remove(lineSegment);
    }
  }

  void updatePath(List<Vector2> newPath) {
    var newLineSegments = <LineSegment>[];
    for(var i = 1; i<newPath.length; i++){
      var lineSegment = LineSegment(pointA: newPath[i-1], pointB: newPath[i]);
      newLineSegments.add(lineSegment);
      if(!pathSegments.keys.contains(lineSegment)){
        generatePathSegment(lineSegment);
      }
    }
    for(var i = 1; i<path.length; i++){
      var lineSegment = LineSegment(pointA: path[i-1], pointB: path[i]);
      if(pathSegments.keys.contains(lineSegment) && !newLineSegments.contains(lineSegment)){
        removePathSegment(lineSegment);
      }
    }
    path = List.from(newPath);
    endPercentageHidden = endPercentageHidden;
  }

  void updatePlayerDistance(double newPlayerDistance){
    for(var i = 1; i<path.length; i++){
      if(i-1 > newPlayerDistance){break;}
      var lineSegment = LineSegment(pointA: path[i-1], pointB: path[i]);
      var pathSegment = pathSegments[lineSegment]!;
      pathSegment.percentageCovered = min(newPlayerDistance-(i-1), 1.0);
    }
  }

  double get endPercentageHidden => _endPercentageHidden;

  set endPercentageHidden(double n){
    _endPercentageHidden = n;
    if(path.length >= 2){
      var lineSegment = LineSegment(pointA: path[0], pointB: path[1]);
      var pathSegment = pathSegments[lineSegment]!;
      pathSegment.percentageHidden = endPercentageHidden;
    }
  }
}

class LineSegment {
  final Vector2 pointA;
  final Vector2 pointB;
  late int uid;

  LineSegment({required this.pointA, required this.pointB}){
    uid = (pointA.x + pointA.y*pow(10, 5) + pointB.x*pow(10, 10) + pointB.y*pow(10, 15)).round();
  }

  @override
  bool operator == (Object other) {
    if(other is LineSegment){
      return pointA == other.pointA && pointB == other.pointB;
    }
    return false;
  }

  @override
  int get hashCode => uid.hashCode;


  @override
  String toString(){
    return "Line Segment " + pointA.toString() + " " + pointB.toString();
  }

}

class PathLineSegment extends PositionComponent{
  final pillsPerTile = 3;
  final pillSpacing = 35.0;
  final pillWidth = 35.0;
  final bool isShadow;
  final coveredColor = Colors.red;
  final uncoveredColor = Colors.white;
  final shadowColor = Color(0xff2B1E30);
  final Vector2 pointA;
  final Vector2 pointB;
  late double _percentageCovered;
  late double _percentageHidden;

  PathLineSegment({required this.pointA, required this.pointB, this.isShadow = false, double initialPercentageCovered = 0.0, double initialPercentageHidden = 0.0}){
    _percentageCovered = initialPercentageCovered;
    _percentageHidden = initialPercentageHidden;
  }

  double get percentageCovered => _percentageCovered;

  double get percentageHidden => _percentageHidden;

  set percentageCovered(n){
    if(_percentageCovered != n){
      _percentageCovered = n;
      regenerate();
    }
  }

  set percentageHidden(n){
    if(_percentageHidden != n){
      _percentageHidden = n;
      regenerate();
    }
  }

  @override
  Future<void>? onLoad() {
    generate();
    return super.onLoad();
  }

  void generate(){
    var pillLength = ((pointA.distanceTo(pointB))-pillsPerTile*pillSpacing)/pillsPerTile;
    var pillPosition = Vector2.copy(pointB);
    var shiftMod = ((pillLength-pillWidth)/2+pillWidth)/pillLength;
    for(var i = 0; i<pillsPerTile+1; i++){
      var pillAngle = atan((pointB.y-pointA.y)/(pointB.x-pointA.x));
      var shift = 0.0;
      var lengthMod = 1.0;

      if(i == 0) {shift = 0.5*shiftMod; lengthMod = shiftMod;}
      if(i == pillsPerTile) {shift = -0.5*shiftMod; lengthMod = shiftMod;}

      Color color = coveredColor;
      if((pillPosition - pointB).length/(pointA-pointB).length < 1-percentageCovered){
        color = uncoveredColor;
      }
      if(isShadow){
        color = shadowColor;
        //pillPosition += Vector2(0.0, 10.0);
      }
      //Generate if not hidden
      if(((pillPosition - pointB).length/(pointA-pointB).length < 1-percentageHidden)){
        generatePill(pillPosition+(pointA-pointB).normalized()*(pillLength*lengthMod-pillWidth)/2, pillAngle, pillLength*lengthMod, pillWidth, Paint()..color = color);
        pillPosition.addScaled((pointA-pointB).normalized(), pillSpacing + lengthMod*pillLength);
      }
    }
  }

  void generatePill(Vector2 pillPosition, double pillAngle, double pillLength, double pillWidth, Paint pillPaint){
    add(PathPill(
      pillPosition: pillPosition + (isShadow ? Vector2(0.0, 12.0) : Vector2(0.0, 0.0)),
      pillAngle: pillAngle,
      pillLength: pillLength,
      pillWidth: pillWidth,
      pillPaint: pillPaint,
    )..priority = 9999999);
  }

  void regenerate(){
    for(var pill in children){
      remove(pill);
    }
    generate();
  }
}

class PathPill extends PositionComponent {
  final double pillLength;
  final double pillWidth;
  final Paint pillPaint;
  PathPill({required Vector2 pillPosition, required this.pillPaint, double pillAngle = 0, this.pillLength = 5, this.pillWidth = 2}){
    position = pillPosition;
    anchor = Anchor.center;
    angle = pillAngle;
  }

  @override
  Future<void>? onLoad() {
    var circleAPosition = Vector2((pillLength-pillWidth)/2, 0);
    var circleBPosition = Vector2.copy(circleAPosition).scaled(-1);
    add(CircleComponent(
      radius: pillWidth/2,
      paint: pillPaint,
      position: circleAPosition,
      anchor: Anchor.center,
    ));
    add(CircleComponent(
      radius: pillWidth/2,
      paint: pillPaint,
      position: circleBPosition,
      anchor: Anchor.center,
    ));
    add(RectangleComponent(
      size: Vector2(pillLength-pillWidth, pillWidth),
      paint: pillPaint,
      anchor: Anchor.center,
    ));
    return super.onLoad();
  }
}