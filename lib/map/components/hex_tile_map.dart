import 'package:flame/components.dart';
import 'package:running_game/map/components/hex_tile/structures/city_structure.dart';
import 'hex_tile/hex_tile.dart';
import 'hex_tile/hex_tile_border.dart';
import 'hex_tile/hex_tile_type.dart';

class HexTileMap {
  List<List<HexTile>> tiles;

  HexTileMap({required this.tiles}) {
    for(var column in tiles){
      for(var tile in column){
        var borders = <HexTileBorder, bool> {};
        var borderingTiles = getBoardingTiles(tile.tilePosition);
        borderingTiles.forEach((borderPosition, borderingTile) {
          borders[borderPosition] = borderingTile is HexTile ? (
              borderingTile.type != tile.type ||
            borderingTile.tileHeight != tile.tileHeight
          ) : false;
        });
        tile.borders = borders;
      }
    }
  }

  factory HexTileMap.empty() {
    return HexTileMap(tiles: []);
  }

  HexTile? getTile(int x, int y){
    if(x >= 0 && x < tiles.length){
      var column = tiles[x];
      if(y >=0 && y < column.length){
        return column[y];
      }
    }
    return null;
  }

  HexTile? getTileFromVector2(Vector2 vec){
    return getTile(vec.x.round(), vec.y.round());
  }

  Map<HexTileBorder, HexTile?> getBoardingTiles(Vector2 tilePosition){
    var offset = tilePosition.x % 2;
    return <int, Map<HexTileBorder, HexTile?>>{
      0: {
        HexTileBorder.topLeft: getTileFromVector2(tilePosition + Vector2(-1, -1)),
        HexTileBorder.topCenter: getTileFromVector2(tilePosition + Vector2(0, -1)),
        HexTileBorder.topRight: getTileFromVector2(tilePosition + Vector2(1, -1)),
        HexTileBorder.bottomLeft: getTileFromVector2(tilePosition + Vector2(-1, 0)),
        HexTileBorder.bottomCenter: getTileFromVector2(tilePosition + Vector2(0, 1)),
        HexTileBorder.bottomRight: getTileFromVector2(tilePosition + Vector2(1, 0)),
      },
      1: {
        HexTileBorder.topLeft: getTileFromVector2(tilePosition + Vector2(-1, 0)),
        HexTileBorder.topCenter: getTileFromVector2(tilePosition + Vector2(0, -1)),
        HexTileBorder.topRight: getTileFromVector2(tilePosition + Vector2(1, 0)),
        HexTileBorder.bottomLeft: getTileFromVector2(tilePosition + Vector2(-1, 1)),
        HexTileBorder.bottomCenter: getTileFromVector2(tilePosition + Vector2(0, 1)),
        HexTileBorder.bottomRight: getTileFromVector2(tilePosition + Vector2(1, 1)),
      },
    }[offset]!;
  }

  Vector2? hexToRealPosition(Vector2 tilePosition){
    return tiles[tilePosition.x.round()][tilePosition.y.round()].hexTop.position;
  }

  Map<HexTile, int> getTilesInRange(Vector2 startingPosition, int minRange, int maxRange){
    var startingTile = getTileFromVector2(startingPosition);
    var inRangeTiles = <HexTile, int> {};
    if(startingTile != null){
      var outerShell = <HexTile>[startingTile];
      var newOuterShell = <HexTile>[];
      var exploredTiles = <HexTile>[startingTile];

      for(var distance = 1; distance <= maxRange; distance += 1){
        for(var tile in outerShell){
          var borderingTiles = getBoardingTiles(tile.tilePosition);
          for(var hexTileBorder in borderingTiles.keys){
            var borderingTile = borderingTiles[hexTileBorder];
            if(borderingTile == null){
              continue; //doesn't exist
            }
            if((borderingTile.tileHeight - tile.tileHeight).abs() >= 2 || borderingTile.type == HexTileType.water){
              continue; //can't travel here
            }
            if(newOuterShell.contains(borderingTile) || exploredTiles.contains(borderingTile)){
              continue; //already searched or added
            }
            newOuterShell.add(borderingTile);
          }
        }
        outerShell = newOuterShell;
        if(distance >= minRange && distance <= maxRange){
          for(var tile in newOuterShell){
            inRangeTiles[tile] = distance;
          }
        }
        exploredTiles.addAll(newOuterShell);
        newOuterShell = [];
      }
    }
    return inRangeTiles;
  }

  Map<HexTileCity, int> getCitiesInRange(Vector2 startingPosition, int minRange, int maxRange){
    var inRangeTiles = getTilesInRange(startingPosition, minRange, maxRange);
    var inRangeCities = <HexTileCity, int> {};
    inRangeTiles.forEach((tile, distance) {
      if(tile.structure is HexTileCity){
        inRangeCities[tile.structure as HexTileCity] = distance;
      }
    });

    return inRangeCities;
  }

  Map<HexTile, int> getNatureInRange(Vector2 startingPosition, int minRange, int maxRange, List<HexTileType>? targetTypes){
    var inRangeTiles = getTilesInRange(startingPosition, minRange, maxRange);
    var inRangeNature = <HexTile, int> {};
    inRangeTiles.forEach((tile, distance) {
      if(targetTypes != null){
        if(targetTypes.contains(tile.type)){
          inRangeNature[tile] = distance;
        }
      } else {
        inRangeNature[tile] = distance;
      }
    });
    return inRangeNature;
  }

}