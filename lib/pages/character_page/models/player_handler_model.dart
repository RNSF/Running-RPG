

import 'dart:math';

import 'package:flutter/cupertino.dart';

class PlayerHandlerModel with ChangeNotifier {
  var xpGained = 35.0;
  var _playerSkin = 0;

  void gainXp(num xpGain) {
    xpGained += xpGain;
  }

  int get level => dirtyLevel.floor();
  double get dirtyLevel => log(xpGained+1)+1.0;
  double get levelProgress => dirtyLevel-level;

  int get playerSkin => _playerSkin;
  set playerSkin(int n){
    _playerSkin = n;
    notifyListeners();
  }
}