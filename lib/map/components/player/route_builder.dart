import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:running_game/map/components/player/player_path.dart';
import "package:running_game/map/components/hex_tile/hex_shape_data.dart";

import '../hex_tile/hex_tile.dart';
import '../hex_tile/hex_tile_selector.dart';
import '../hex_tile_map.dart';

class PlayerRouteBuilder extends PositionComponent{

  Map<Vector2, HexTileSelector> extensions = {};
  PlayerPath playerPath;

  PlayerRouteBuilder({required this.playerPath});

  void updatePossibleExtensions(HexTileMap hexTileMap){
    var endPosition = playerPath.path.last;
    removeAllExtensions(hexTileMap);
    if(hexTileMap.getTileFromVector2(endPosition) != null){
      var endPositionHeight = hexTileMap.getTileFromVector2(endPosition)!.height;
      hexTileMap.getBoardingTiles(endPosition).forEach((borderPosition, tile) {
        bool validExtension = tile != null && ((playerPath.path.length >= 2 ? playerPath.path[playerPath.path.length-2] : null) != tile.tilePosition && (endPositionHeight-tile.height).abs() < 2);
        if(validExtension) {
          addExtension(tile);
        }
      });
    }
  } 

  void addExtension(HexTile tile){
    extensions[tile.tilePosition] = tile.addSelector(extensionOnPressed, HexTileSelectorType.pathBuilder);
  }

  void removeExtension(HexTile tile){
    tile.removeSelector(HexTileSelectorType.pathBuilder);
    extensions.remove(tile.tilePosition);
  }

  void removeAllExtensions(HexTileMap hexTileMap){
    var extensionsCopy = {...extensions};
    extensionsCopy.forEach((position, extension) {
      var tile = hexTileMap.getTileFromVector2(position);
      if(tile != null){
        removeExtension(tile);
      }
    });
  }

  void extensionOnPressed(TapUpInfo tapUpInfo, HexTileSelector hexTileSelector){
    playerPath.add(hexTileSelector.tilePosition);
  }
}
