import 'package:flame/components.dart';
import 'package:flame_svg/svg.dart';

import '../hex_tile_decal.dart';
import 'hex_tile_structure.dart';

class HexTileCity extends HexTileStructure{

  final int spriteSize;
  final int spriteId;
  final CityStats stats;

  HexTileCity({required this.stats, this.spriteSize = 1, this.spriteId = 1, String? name, required Vector2 mapCoordinates, String? description}) : super(name: name ?? "Unnamed", description: description ?? "No description.", mapCoordinates: mapCoordinates);

  @override
  Future<void>? onLoad() async {
    svg = await Svg.load("images/world_map/structures/cities/S${spriteSize}City${spriteId}.svg");
    size = Vector2(300, 300);
    return super.onLoad();
  }

  @override
  HexTileDecalType? getDecalType(){
    /*
    var brightness = <HexTileType?, String>{
      null: "D",
      HexTileType.deepForest: "D",
      HexTileType.mountain : "D",
      HexTileType.forest : "D",
      HexTileType.sand : "D",
      HexTileType.water : "D",
      HexTileType.grassland : "B",
      HexTileType.dirt: "B",
    }[tileType] ?? "D";

     */
    var brightness = "D";

    var dirtSize = <int, String> {
      1: "S",
      2: "M",
      3: "M",
      4: "L",
      5: "L",
    }[spriteSize] ?? "L";

    switch(brightness+dirtSize){
      case "DS":
        return HexTileDecalType.buildingDirtSmallDark;
      case "DM":
        return HexTileDecalType.buildingDirtMediumDark;
      case "DL":
        return HexTileDecalType.buildingDirtLargeDark;
      case "BS":
        return HexTileDecalType.buildingDirtSmallLight;
      case "BM":
        return HexTileDecalType.buildingDirtMediumLight;
      case "BL":
        return HexTileDecalType.buildingDirtLargeLight;
    }
    return HexTileDecalType.buildingDirtLargeDark;
  }
}



class CityStats {
  final double wealth;
  final double size;
  final double holyMagic;
  final double natureMagic;
  final double scholardarity;
  final double military;
  final double port;
  final double farming;
  final double lumber;
  final double mining;

  const CityStats({
    this.wealth = 0.0,
    this.size = 0.0,
    this.holyMagic = 0.0,
    this.natureMagic = 0.0,
    this.scholardarity = 0.0,
    this.military = 0.0,
    this.port = 0.0,
    this.farming = 0.0,
    this.lumber = 0.0,
    this.mining = 0.0,
  });

  factory CityStats.fromJson(Map<String, dynamic> json){
    return CityStats(
      wealth: json["wealth"].toDouble() ?? 0.0,
      size: json["size"].toDouble() ?? 0.0,
      holyMagic: json["holy_magic"].toDouble() ?? 0.0,
      natureMagic: json["nature_magic"].toDouble() ?? 0.0,
      scholardarity: json["scholardarity"].toDouble() ?? 0.0,
      military: json["military"].toDouble() ?? 0.0,
      port: json["port"].toDouble() ?? 0.0,
      farming: json["farming"].toDouble() ?? 0.0,
      lumber: json["lumber"].toDouble() ?? 0.0,
      mining: json["mining"].toDouble() ?? 0.0,
    );
  }

  Map<String, double> toJson(){
    return <String, double>{
      "wealth" : wealth,
      "size" : size,
      "holy_magic" : holyMagic,
      "nature_magic" : natureMagic,
      "scholardarity" : scholardarity,
      "military" : military,
      "port" : port,
      "farming" : farming,
      "lumber" : lumber,
      "mining" : mining,
    };
  }
}
