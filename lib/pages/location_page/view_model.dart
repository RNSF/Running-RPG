import 'package:flutter/cupertino.dart';
import 'package:running_game/pages/quest_page/models/quest_handler_model.dart';

import '../../locator.dart';

class LocationPageViewModel extends ChangeNotifier {
  final questHandler = locator.get<QuestHandlerModel>();

  BuildContext context;

  LocationPageViewModel({required this.context});

  String get locationName => questHandler.currentLocationName ?? "The Wilderness";
  bool get atCity => questHandler.currentLocationName != null;

  void onQuestButtonPressed(){
    Navigator.of(context).pushNamed("/quest_page");
    return;
  }

  void onShopButtonPressed(){
    return;
  }

  void onCraftButtonPressed(){
    return;
  }

  void onMapButtonPressed(){
    return;
  }
}