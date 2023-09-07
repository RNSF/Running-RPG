
import 'package:flutter/cupertino.dart';

import '../../locator.dart';
import 'models/player_handler_model.dart';

class CharacterPageViewModel extends ChangeNotifier {

  final playerHandler = locator.get<PlayerHandlerModel>();

  CharacterPageViewModel(){
    playerHandler.addListener(onPlayerHandlerUpdated);
  }

  int get level => playerHandler.level;
  double get levelProgress => playerHandler.levelProgress;
  int get playerSkin => playerHandler.playerSkin;

  void onInventoryButtonPressed(int index) {
    playerHandler.playerSkin = index;
  }

  void onPlayerHandlerUpdated(){
    notifyListeners();
  }
}