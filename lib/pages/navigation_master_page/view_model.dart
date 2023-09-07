import 'dart:async';

import 'package:flutter/material.dart';
import 'package:running_game/pages/navigation_master_page/remote_controller_model.dart';
import 'package:running_game/pages/navigation_master_page/remote_controller_model.dart';

import '../../locator.dart';
import '../character_page/view.dart';
import '../location_page/view.dart';
import '../map_page/view.dart';

class NavigationMasterPageViewModel extends ChangeNotifier{
  var _currentIndex = 0;
  late PageController pageController;
  final remoteNavigationController = locator.get<RemoteNavigationControllerModel>();


  NavigationMasterPageViewModel(){
    pageController = PageController(
      initialPage: _currentIndex,
    );
    remoteNavigationController.addListener(onRemoteNavigationControllerUpdate);
  }

  set currentIndex(n) {
    _currentIndex = n;
    pageController.animateToPage(currentIndex, curve: Curves.easeOutCirc, duration: Duration(milliseconds: 300));
    print("MOVING TO PAGE: $currentIndex");
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

  void onNavigationButtonTap(int buttonIndex){
    currentIndex = buttonIndex;
  }

  void onRemoteNavigationControllerUpdate(){
    if(remoteNavigationController.queuedSwitch != null){
      currentIndex = <String, int>{
        "Map" : 0,
        "Location" : 1,
        "Character" : 2,
      }[remoteNavigationController.queuedSwitch];
      remoteNavigationController.queuedSwitch = null;
    }
  }

}