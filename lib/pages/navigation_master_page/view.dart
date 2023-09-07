import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:running_game/pages/navigation_master_page/view_model.dart';
import '../character_page/view.dart';
import '../location_page/view.dart';
import '../map_page/view.dart';

class NavigationMasterPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var viewModel = NavigationMasterPageViewModel();

    return ChangeNotifierProvider<NavigationMasterPageViewModel>(
      create: (context) => viewModel,
      builder: (context, _) {
        viewModel = Provider.of<NavigationMasterPageViewModel>(context);
        return SafeArea(
          child: Scaffold(
            body: PageView(
              controller: viewModel.pageController,
              children: [
                const MapPage(),
                const LocationPage(),
                const CharacterPage(),
              ],
              //onPageChanged: viewModel.onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: Consumer<NavigationMasterPageViewModel>(builder: (context, vM, _) {
              return BottomNavigationBar(
                currentIndex: vM.currentIndex,
                onTap: vM.onNavigationButtonTap,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    activeIcon: Icon(Icons.map),
                    label: "Map",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.nature_outlined),
                    activeIcon: Icon(Icons.nature),
                    label: "Location",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "Character",
                  ),
                ],
              );
            }),
          ),
        );
      }
    );
  }
}
