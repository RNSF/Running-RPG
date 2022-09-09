import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';

import '../../../pages/quest_page/models/quest.dart';

class HexTileQuestMarker extends SvgComponent{
  final int localQuestId;
  final Vector2 tilePosition;

  HexTileQuestMarker({required this.localQuestId, required this.tilePosition}){
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void>? onLoad() async {
    svg = await Svg.load(bannerPath);
    return super.onLoad();
  }

  String get bannerPath => "assets/images/world_map/quest_markers/Banner${{0:"A", 1:"B",2:"C",3:"D"}[localQuestId]}.svg";

}