import 'package:flutter/cupertino.dart';
import "package:get_it/get_it.dart";
import 'package:running_game/pages/character_page/models/player_handler_model.dart';
import 'package:running_game/pages/navigation_master_page/remote_controller_model.dart';
import 'package:running_game/pages/quest_page/models/quest_handler_model.dart';
import 'package:running_game/saving_service/saving_service.dart';

final locator = GetIt.instance;
var isLocatorSetUp = false;

Future<void> setUpLocator(BuildContext context) async {
  if(!isLocatorSetUp){
    isLocatorSetUp = true;
    locator.registerSingleton<SaveDataHandler>(SaveDataHandler());
    var saveDataHandler = locator.get<SaveDataHandler>();
    //await saveDataHandler.loadData();
    locator.registerSingleton<RemoteNavigationControllerModel>(RemoteNavigationControllerModel());
    locator.registerSingleton<QuestHandlerModel>(QuestHandlerModel.fromJson(saveDataHandler.findMap(["game", "quests"]) ?? {}));
    locator.registerSingleton<PlayerHandlerModel>(PlayerHandlerModel());
    await locator.get<QuestHandlerModel>().loadQuestGivers(context);
  }
}