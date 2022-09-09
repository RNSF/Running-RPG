import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_type.dart';

import '../hex_tile.dart';
import '../hex_tile_decal.dart';
import 'city_structure.dart';

class HexTileStructure extends SvgComponent{

  final String name;
  final String description;
  HexTileDecalType? forcedDecalType;
  HexTileType tileType;
  Vector2 mapCoordinates;
  HexTileStructure({required this.mapCoordinates, this.name = "Unknown Structure", this.forcedDecalType, this.tileType = HexTileType.grassland, this.description = "A very strange structure."}) : super(
    anchor: const Anchor(100/200, 170/200),
  );

  factory HexTileStructure.fromJson(json){
    var data = json["data"];
    switch(json["type"]) {
      case "city": {
        return HexTileCity(spriteSize: data["sprite_size"], spriteId: data["id"], name: data["name"], mapCoordinates: Vector2(data["position"]["x"].toDouble(), data["position"]["y"].toDouble()),
            stats: CityStats.fromJson(data["stats"]), description: data["description"],
        );
      };
    };
    return HexTileStructure(mapCoordinates: Vector2.zero());
  }

  HexTileDecalType? getDecalType(){}


}
