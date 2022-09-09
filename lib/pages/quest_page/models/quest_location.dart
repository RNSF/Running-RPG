import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../json_converters/vector2_json_converter.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';

part "quest_location.g.dart";

@JsonSerializable()
class QuestLocation {
  @Vector2JsonConverter()
  final Vector2? mapCoordinates;
  final String name;
  @JsonKey(ignore: true)
  late final String uid;

  QuestLocation({this.mapCoordinates, this.name = ""}){
    uid = "$mapCoordinates$name";
  }

  factory QuestLocation.fromJson(Map json) => _$QuestLocationFromJson(json);
  Map<String, dynamic> toJson() => _$QuestLocationToJson(this);

  factory QuestLocation.fromHexTileCity(HexTileCity city){
    return QuestLocation(mapCoordinates: city.mapCoordinates, name: city.name);
  }

  @override
  bool operator == (Object other) {
    if(other is QuestLocation){
      return mapCoordinates == other.mapCoordinates && name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => uid.hashCode;

}