// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerPath _$PlayerPathFromJson(Map json) => PlayerPath(
      playerPosition: json['playerPosition'] == null
          ? null
          : PlayerPosition.fromJson(json['playerPosition'] as Map),
    )..path = (json['path'] as List<dynamic>)
        .map((e) => const Vector2JsonConverter().fromJson(e as Map))
        .toList();

Map<String, dynamic> _$PlayerPathToJson(PlayerPath instance) =>
    <String, dynamic>{
      'path': instance.path.map(const Vector2JsonConverter().toJson).toList(),
      'playerPosition': instance.playerPosition?.toJson(),
    };
