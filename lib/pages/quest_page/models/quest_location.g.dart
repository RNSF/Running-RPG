// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestLocation _$QuestLocationFromJson(Map json) => QuestLocation(
      mapCoordinates: _$JsonConverterFromJson<Map<dynamic, dynamic>, Vector2>(
          json['mapCoordinates'], const Vector2JsonConverter().fromJson),
      name: json['name'] as String? ?? "",
    );

Map<String, dynamic> _$QuestLocationToJson(QuestLocation instance) =>
    <String, dynamic>{
      'mapCoordinates': _$JsonConverterToJson<Map<dynamic, dynamic>, Vector2>(
          instance.mapCoordinates, const Vector2JsonConverter().toJson),
      'name': instance.name,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
