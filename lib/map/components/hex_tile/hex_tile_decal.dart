
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';

enum HexTileDecalType {
  empty,
  buildingDirtSmallLight,
  buildingDirtMediumLight,
  buildingDirtLargeLight,
  buildingDirtSmallDark,
  buildingDirtMediumDark,
  buildingDirtLargeDark,
  grass,
  rocks,
  sand,
}

class HexTileDecal extends SvgComponent{
  final HexTileDecalType type;
  final bool mirrorable;

  HexTileDecal({required this.type, this.mirrorable = true}) {
    switch(type) {
      case HexTileDecalType.buildingDirtLargeDark:
      case HexTileDecalType.buildingDirtMediumDark:
      case HexTileDecalType.buildingDirtSmallDark:
      case HexTileDecalType.buildingDirtLargeLight:
      case HexTileDecalType.buildingDirtMediumLight:
      case HexTileDecalType.buildingDirtSmallLight:
        anchor = const Anchor(0.5, 0.25);
        break;
      case HexTileDecalType.grass:
      case HexTileDecalType.sand:
      case HexTileDecalType.rocks:
        anchor = const Anchor(0.5, 0.5);
        break;
    }
  }

  @override
  Future<void>? onLoad() async {
    svg = await Svg.load(getAssetPath());
    size = Vector2(300, 300);
    if(mirrorable){
      scale = Vector2(Random().nextInt(1) * 2 -1, 1);
    }
    return super.onLoad();
  }

  String getAssetPath() {
    var basePath = "images/world_map/decals/";
    var rn = Random().nextInt(999999);
    switch(type) {
      case HexTileDecalType.buildingDirtLargeDark:
        return basePath+"building_dirt/dark/L${rn%3+1}.svg";
      case HexTileDecalType.buildingDirtMediumDark:
        return basePath+"building_dirt/dark/M${rn%3+1}.svg";
      case HexTileDecalType.buildingDirtSmallDark:
        return basePath+"building_dirt/dark/S${rn%3+1}.svg";
      case HexTileDecalType.buildingDirtLargeLight:
        return basePath+"building_dirt/light/L${rn%3+1}.svg";
      case HexTileDecalType.buildingDirtMediumLight:
        return basePath+"building_dirt/light/M${rn%3+1}.svg";
      case HexTileDecalType.buildingDirtSmallLight:
        return basePath+"building_dirt/light/S${rn%3+1}.svg";
      case HexTileDecalType.grass:
        return basePath+"grass/grass${rn%9+1}.svg";
      case HexTileDecalType.sand:
        return basePath+"sand/sand${rn%9+1}.svg";
      case HexTileDecalType.rocks:
        return basePath+"rock/rock${rn%9+1}.svg";
    }
    return "";
  }
}