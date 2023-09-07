enum HexTileType {
  water,
  grassland,
  sand,
  forest,
  deepForest,
  mountain,
  dirt,
}

HexTileType StringToHexTileType(String text){
  text = text.toLowerCase();
  return <String, HexTileType>{
    "water": HexTileType.water,
    "grassland": HexTileType.grassland,
    "fields": HexTileType.grassland,
    "sand": HexTileType.sand,
    "forest": HexTileType.forest,
    "deep forest": HexTileType.deepForest,
    "mountain": HexTileType.mountain,
    "dirt": HexTileType.dirt,
  }[text] ?? HexTileType.water;
}