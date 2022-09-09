

import 'package:flame/components.dart';
import 'package:flame/layers.dart';

import 'hex_tile/hex_tile.dart';

class MapLayer extends PreRenderedLayer {
  final List<HexTile> components;

  MapLayer({required this.components});

  @override
  void drawLayer() {
    for(var component in components){
      component.render(canvas);
      component.decal?.svg?.render(canvas, Vector2(200, 200));
    }
  }

}