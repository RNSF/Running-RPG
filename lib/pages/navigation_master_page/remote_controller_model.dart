import 'dart:async';

import 'package:flutter/cupertino.dart';

class RemoteNavigationControllerModel extends ChangeNotifier{
  String? queuedSwitch;

  void queueSwitch(String pageName) {
    queuedSwitch = pageName;
    notifyListeners();
  }
}