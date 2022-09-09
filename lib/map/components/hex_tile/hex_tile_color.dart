import 'package:flutter/material.dart';
import 'hex_tile_type.dart';

class HexTileColor {
  final Color topColor;
  final Color sideColor;

  HexTileColor({this.topColor = Colors.white, this.sideColor = Colors.grey});

  factory HexTileColor.fromTileType(HexTileType tileType) {
    return {
      HexTileType.water : HexTileColor(topColor: Color(0xff36C5F4), sideColor: Color(0xff3388DE)),
      HexTileType.grassland : HexTileColor(topColor: Color(0xff5AB552), sideColor: Color(0xff26854C)),
      HexTileType.sand : HexTileColor(topColor: Color(0xffDAB163), sideColor: Color(0xffCE9248)),
      HexTileType.forest : HexTileColor(topColor: Color(0xff26854C), sideColor: Color(0xff006554)),
      HexTileType.deepForest : HexTileColor(topColor: Color(0xff006554), sideColor: Color(0xff1E4044)),
      HexTileType.mountain : HexTileColor(topColor: Color(0xff8C78A5), sideColor: Color(0xff5E5B8C)),
      HexTileType.dirt : HexTileColor(topColor: Color(0xff6E4C30), sideColor: Color(0xff4D3533)),
    }[tileType] ?? HexTileColor();
  }
}
