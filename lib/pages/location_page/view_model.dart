import 'package:flutter/cupertino.dart';

class LocationPageViewModel extends ChangeNotifier {
  BuildContext context;

  LocationPageViewModel({required this.context});

  String get locationName => "Unnamed Location";

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