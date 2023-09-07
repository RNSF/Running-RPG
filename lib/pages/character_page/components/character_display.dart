import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:running_game/pages/character_page/view_model.dart';

class CharacterDisplay extends StatelessWidget {
  final CharacterPageViewModel viewModel;
  final backgroundAspectRatio = 987.0/787.0;

  const CharacterDisplay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SvgPicture.asset(
        "assets/images/character_page/background.svg",
        semanticsLabel: 'Background',
        width: MediaQuery.of(context).size.width,
      ),
      Container(
        alignment: Alignment(Alignment.bottomCenter.x, Alignment.bottomCenter.y-0.17),
        height: MediaQuery.of(context).size.width/backgroundAspectRatio,
        child: SvgPicture.asset(
          "assets/images/character_page/player_shadow.svg",
          semanticsLabel: 'Background',
          width: MediaQuery.of(context).size.width/3.5,
          alignment: Alignment.center,
        ),
      ),
      Container(
        alignment: Alignment(Alignment.bottomCenter.x-0.02, Alignment.bottomCenter.y-0.4),
        height: MediaQuery.of(context).size.width/backgroundAspectRatio,
        child: SvgPicture.asset(
          "assets/images/character_page/player${viewModel.playerSkin+1}.svg",
          semanticsLabel: 'Background',
          width: MediaQuery.of(context).size.width/3,
          alignment: Alignment.center,
        ),
      ),
    ]);
  }
}
