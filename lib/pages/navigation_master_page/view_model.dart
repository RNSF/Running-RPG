import 'package:flutter/material.dart';

import '../character_page/view.dart';
import '../location_page/view.dart';
import '../map_page/view.dart';

class NavigationMasterPageViewModel extends ChangeNotifier{
  var _currentIndex = 0;
  late PageController pageController;

  NavigationMasterPageViewModel(){
    pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  set currentIndex(n) {
    _currentIndex = n;
    pageController.animateToPage(currentIndex, curve: Curves.easeOutCirc, duration: Duration(milliseconds: 300));
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

  void onPageChanged(int newIndex){
    currentIndex = newIndex;
  }

  void onNavigationButtonTap(int buttonIndex){
    currentIndex = buttonIndex;
  }

}