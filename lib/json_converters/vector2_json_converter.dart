import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';

class Vector2JsonConverter implements JsonConverter<Vector2, Map> {
  const Vector2JsonConverter();

  @override
  Vector2 fromJson(Map json) => Vector2(json["x"] ?? 0, json["y"] ?? 0);

  @override
  Map<String, double> toJson(Vector2 vector2) => {"x" : vector2.x, "y" : vector2.y};
}