import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:running_game/pages/character_page/view_model.dart';

import 'components/character_display.dart';
import 'components/inventory_display.dart';
import 'components/level_info.dart';

class CharacterPage extends StatelessWidget {
  
  const CharacterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = CharacterPageViewModel();
    return ChangeNotifierProvider<CharacterPageViewModel>(
      create: (context) => viewModel,
      builder: (context, _) {
        viewModel = Provider.of<CharacterPageViewModel>(context);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          LevelInfo(viewModel: viewModel),
          CharacterDisplay(viewModel: viewModel),
          InventoryDisplay(viewModel: viewModel),
        ],);
      }
    );
  }
}
