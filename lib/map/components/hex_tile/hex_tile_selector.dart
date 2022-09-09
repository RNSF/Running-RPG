import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

import 'hex_shape_data.dart';

enum HexTileSelectorType {
  pathBuilder,
  structure,
  questView,
}

class HexTileSelector extends SvgComponent with Tappable, GestureHitboxes {
  Vector2 tilePosition;
  late final PolygonHitbox hitbox = PolygonHitbox([
        Vector2(1*sideLength, 0*sideLength*sqrt(3)/2),
        Vector2(0.5*sideLength, -1*sideLength*sqrt(3)/2),
        Vector2(-0.5*sideLength, -1*sideLength*sqrt(3)/2),
        Vector2(-1*sideLength, 0*sideLength*sqrt(3)/2),
        Vector2(-0.5*sideLength, 1*sideLength*sqrt(3)/2),
        Vector2(0.5*sideLength, 1*sideLength*sqrt(3)/2),
      ]
    )
  ..anchor = Anchor.center
  ..position = Vector2(sideLength, sqrt(3)/2*sideLength);

  final Function(TapUpInfo, HexTileSelector) onPressed;
  bool _active = true;
  final HexTileSelectorType type;

  HexTileSelector({required this.onPressed, required this.tilePosition, required this.type});

  @override
  Future<void> onLoad() async {
    svg = await Svg.load(<HexTileSelectorType, String>{
      HexTileSelectorType.pathBuilder: "images/world_map/hex_selector/hex_selector.svg",
      HexTileSelectorType.structure: "images/blank.svg",
      HexTileSelectorType.questView: "images/world_map/hex_selector/hex_selector.svg",
    }[type] ?? "");
    anchor = Anchor.center;
    size = Vector2(sideLength, sqrt(3)/2*sideLength)*1.8;
    add(hitbox);
    return super.onLoad();
  }

  set active(n){
    _active = n;
    hitbox.scale = _active ? Vector2(1, 1) : Vector2.zero();
  }

  bool get active => _active;



  @override
  bool onTapUp(TapUpInfo info) {
    onPressed(info, this);
    return super.onTapUp(info);
  }

}

class TileHitBox extends PolygonHitbox with Tappable {

  Function(TapUpInfo) onPressed;
  TileHitBox({required this.onPressed}) : super.relative(hexVertices, parentSize: Vector2(sideLength*2, sideLength*sqrt(3)));

  @override
  bool onTapUp(TapUpInfo info) {
    onPressed(info);
    return super.onTapUp(info);
  }
}