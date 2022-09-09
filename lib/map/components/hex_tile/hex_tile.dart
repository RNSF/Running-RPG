import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_border.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_color.dart';

import 'hex_tile_decal.dart';
import 'hex_tile_quest_marker.dart';
import 'hex_tile_selector.dart';
import 'structures/hex_tile_structure.dart';
import 'hex_tile_type.dart';
import "hex_shape_data.dart";



class HexTile extends PositionComponent {
  final HexTileType type;
  final int tileHeight;
  final HexTileStructure? structure;
  List<HexTileSelector> selectors = [];
  List<HexTileQuestMarker> questMarkers = [];
  late final HexTileDecal? decal;
  Vector2 tilePosition;
  Map<HexTileBorder, bool> _borders = {};

  late final HexTop hexTop;
  late final HexSide hexSide;
  Map<HexTileBorder, HexBorder> hexBorders = {};

  HexTile({
    required this.tilePosition,
    this.type = HexTileType.water,
    this.tileHeight = 0,
    this.structure,
  }) : super() {
    var hexTileColor = HexTileColor.fromTileType(type);
    hexTop = HexTop(color: hexTileColor.topColor)
      ..position = -Vector2(0, tileHeight*heightLength)
      ..priority = 0;
    hexSide = HexSide(color: hexTileColor.sideColor, height: tileHeight)
      ..position = -Vector2(0, heightLength*tileHeight)
      ..priority = 1;
    structure?.priority = 3;
    structure?.position = Vector2(0, 70) + hexTop.position;
    structure?.tileType = type;
    structure?.forcedDecalType = structure?.getDecalType();

    if(structure?.forcedDecalType is HexTileDecalType) {
      decal = HexTileDecal(type: structure!.forcedDecalType!);
    } else {
      decal = generateRandomDecal(type);
    }

    decal?.priority = 2;
    decal?.position = hexTop.position;

  }

  factory HexTile.fromJson(Map<String, dynamic> json) {
    return HexTile(
      tileHeight: json["height"] ?? 0,
      type: HexTileType.values[json["type"] ?? 0],
      tilePosition: Vector2(json["position"]["x"].toDouble() ?? 0, json["position"]["y"].toDouble() ?? 0),
      structure: json["structure"]["type"] == "empty" ? null : HexTileStructure.fromJson(json["structure"]),
    );
  }


  @override
  Future<void>? onLoad() {
    add(hexTop);
    add(hexSide);
    if(structure is HexTileStructure){add(structure!);}
    if(decal is HexTileDecal){add(decal!);}
    return super.onLoad();
  }


  Map<HexTileBorder, bool> get borders => _borders;

  set borders(Map<HexTileBorder, bool> newBorders){
    _borders = newBorders;
    updateHexBorders();
  }

  void updateHexBorders(){
    var hexTileColor = HexTileColor.fromTileType(type);
    borders.forEach((borderPosition, borderExists) {
      if(hexBorders.containsKey(borderPosition) && !borderExists){
        //Remove border
        remove(hexBorders[borderPosition]!);
        hexBorders.remove(borderPosition);
      }
      if(borderExists && !hexBorders.containsKey(borderPosition)){
        //Add border
        var hexBorder = HexBorder(color: hexTileColor.sideColor, borderPosition: borderPosition)
          ..position = -Vector2(0, tileHeight*heightLength)
          ..priority = 2;
        hexBorders[borderPosition] = hexBorder;
        add(hexBorder);
      }
    });
  }

  HexTileDecal? generateRandomDecal(HexTileType type){
    switch(type) {
      case HexTileType.grassland:
        if(Random().nextInt(5) == 0){
          return HexTileDecal(type: HexTileDecalType.grass);
        } break;
      case HexTileType.sand:
        if(Random().nextInt(3) == 0){
          return HexTileDecal(type: HexTileDecalType.sand);
        } break;
      case HexTileType.mountain:
        if(Random().nextInt(8) == 0){
          return HexTileDecal(type: HexTileDecalType.rocks);
        } break;
    }
    return null;
  }

  HexTileSelector addSelector(Function(TapUpInfo, HexTileSelector) onPressed, HexTileSelectorType selectorType){
    if(selectors.isNotEmpty){selectors.last.active = false;}
    selectors.add(HexTileSelector(onPressed: onPressed, tilePosition: tilePosition, type: selectorType)
      ..size = Vector2(sideLength*2, sideLength*sqrt(3))
      ..position = hexTop.position
      ..active = true);
    add(selectors.last);
    return selectors.last;
  }

  void removeSelector(HexTileSelectorType selectorType) {
    for(var selector in List.from(selectors)){
      if(selector.type == selectorType){
        remove(selector);
        selectors.remove(selector);
      }
      if(selectors.isNotEmpty){
        selectors.last.active = true;
      }
    }
  }

  set onStructurePressed(Function(TapUpInfo, HexTileSelector) n){
    if(structure != null){
      removeSelector(HexTileSelectorType.structure);
      addSelector(n, HexTileSelectorType.structure);
    }
  }

  void addQuestMarker(int localQuestId){
    for(var questMarker in questMarkers){
      if(questMarker.localQuestId == localQuestId){return;}
    }
    var questMarker = HexTileQuestMarker(localQuestId: localQuestId, tilePosition: tilePosition);
    questMarkers.add(questMarker);
    add(questMarker);
    adjustQuestMarkers();
  }

  void removeQuestMarker(int localQuestId){
    for(var questMarker in List<HexTileQuestMarker>.from(questMarkers)){
      if(questMarker.localQuestId == localQuestId){
        remove(questMarker);
        questMarkers.remove(questMarker);
      }
    }
    adjustQuestMarkers();
  }

  void adjustQuestMarkers(){
    var angleDifference = 20/360*2*pi;
    var markerAngle = angleDifference*(questMarkers.length-1)*0.5;
    var positionDifference = Vector2(20, 0);
    var markerPosition = Vector2(0, 70);

    for(var questMarker in List<HexTileQuestMarker>.from(questMarkers)){
      questMarker.angle = markerAngle;
      questMarker.position = markerPosition;
      markerPosition += positionDifference;
      markerAngle += angleDifference;
    }
  }
}


class HexTop extends PolygonComponent {

  HexTop({Color color = Colors.white}) : super.relative(
    hexVertices,
    parentSize: Vector2(sideLength*2, sideLength*sqrt(3)),
    anchor: Anchor(0.5, 0.5),
    paint: Paint()
      ..color = color
      ..isAntiAlias = false
  );
}

class HexSide extends PolygonComponent {

  HexSide({Color color = Colors.white, int height = 0}) : super(
    [
      Vector2(-sideLength, 0),
      Vector2(-0.5*sideLength, sideLength*sqrt(3)/2),
      Vector2(0.5*sideLength, sideLength*sqrt(3)/2),
      Vector2(sideLength, 0),
      Vector2(sideLength, heightLength*height),
      Vector2(0.5*sideLength, heightLength*height+sideLength*sqrt(3)/2),
      Vector2(-0.5*sideLength, heightLength*height+sideLength*sqrt(3)/2),
      Vector2(-sideLength, heightLength*height),
    ],
    paint: Paint()
      ..color = color
      ..isAntiAlias = false,
    anchor: Anchor(0.5, 0),
  );
}

class HexBorder extends PolygonComponent {

  HexBorder({Color color = Colors.white, HexTileBorder borderPosition = HexTileBorder.topLeft, double thickness = 15}) : super(
    [
      Vector2(-0.5*sideLength, -1*sideLength),
      Vector2(0.5*sideLength, -1*sideLength),
      Vector2(0.5*sideLength+1/sqrt(3)*thickness, -1*sideLength+thickness),
      Vector2(-0.5*sideLength-1/sqrt(3)*thickness, -1*sideLength+thickness),
    ],
    paint: Paint()
      ..color = color
      ..isAntiAlias = false,
    anchor: Anchor(0.5, sideLength*(sqrt(3)/2)/thickness),
    angle: <HexTileBorder, double> {
      HexTileBorder.topCenter :     2*pi*0/6,
      HexTileBorder.topRight :      2*pi*1/6,
      HexTileBorder.bottomRight :   2*pi*2/6,
      HexTileBorder.bottomCenter :  2*pi*3/6,
      HexTileBorder.bottomLeft :    2*pi*4/6,
      HexTileBorder.topLeft :       2*pi*5/6,
    }[borderPosition]
  );

  List<Vector2> getVertices(HexTileBorder borderPosition, double thickness) {
    return <HexTileBorder, List<Vector2>> {
    }[borderPosition] ?? [];
  }
}