import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_game/pages/loading_page/loading_page.dart';
import 'package:running_game/pages/map_page/view.dart';
import 'package:running_game/pages/map_page/view_model.dart';
import 'package:running_game/pages/navigation_master_page/view.dart';
import 'package:running_game/pages/navigation_master_page/view_model.dart';
import 'package:running_game/pages/quest_page/view.dart';
import 'package:running_game/pages/quest_page/view_model.dart';
import 'package:running_game/saving_service/saving_service.dart';
import 'package:running_game/theme/theme_data.dart';

import 'locator.dart';
import 'map/world_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: "/loading_page",
      theme: standardTheme,
      routes: {
        "/loading_page" : (context) => LoadingPage(),
        "/map_page" : (context) => MapPage(),
        "/navigation_master" : (context) => NavigationMasterPage(),
        "/quest_page" : (context) => QuestPage(),
      },
    );


  }
}


