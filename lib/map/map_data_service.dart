import 'dart:convert';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'components/hex_tile/hex_shape_data.dart';
import 'components/hex_tile/hex_tile.dart';
import 'components/hex_tile/hex_tile_border.dart';
import 'components/hex_tile_map.dart';

class WorldMapData {

  HexTileMap generateGroundFromJson(List json){
    List<List<HexTile>> hexMap = [];
    json.asMap().forEach((x, column) {
      hexMap.add([]);
      column.asMap().forEach((y, tileData) {
        var offset = x % 2;
        hexMap[x].add(
          HexTile.fromJson(tileData)
            ..position = Vector2(x*sideLength*1.5, (y+offset*1/2)*sideLength*sqrt(3))
            ..priority = y*2+offset,
        );
      });
    });
    return HexTileMap(tiles: hexMap);
  }
}