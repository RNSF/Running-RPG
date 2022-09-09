import 'dart:math';

import 'package:flame/components.dart';

const sideLength = 200.0;
const heightLength = 50.0;
final hexVertices = [
  Vector2(1, 0),
  Vector2(0.5, -1),
  Vector2(-0.5, -1),
  Vector2(-1, 0),
  Vector2(-0.5, 1),
  Vector2(0.5, 1),
];

final hexVerticesScaled = [
  Vector2(1*sideLength, 0*sideLength*sqrt(3)/2),
  Vector2(0.5*sideLength, -1*sideLength*sqrt(3)/2),
  Vector2(-0.5*sideLength, -1*sideLength*sqrt(3)/2),
  Vector2(-1*sideLength, 0*sideLength*sqrt(3)/2),
  Vector2(-0.5*sideLength, 1*sideLength*sqrt(3)/2),
  Vector2(0.5*sideLength, 1*sideLength*sqrt(3)/2),
];