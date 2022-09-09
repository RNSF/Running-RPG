import 'dart:math';

import 'package:flutter/material.dart';
import 'package:running_game/pages/location_page/view_model.dart';

import '../../widget_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override

  Widget build(BuildContext context) {
    var viewModel = LocationPageViewModel(context: context);
    return Column(
      children: [
        LocationTitle(viewModel: viewModel),
        Painting(viewModel: viewModel),
        Expanded(flex: 1, child: Menu(viewModel: viewModel)),
      ],
    );
  }
}


class LocationTitle extends StatelessWidget {

  final LocationPageViewModel viewModel;

  const LocationTitle({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff6E4C30),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 24.0,
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: SizedBox()),
              Text(
                viewModel.locationName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(flex: 1, child: SizedBox()),
            ],
          )
        ),
      ),
    );
  }
}


class Painting extends StatelessWidget {

  final LocationPageViewModel viewModel;

  const Painting({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: 250);
  }
}


class Menu extends StatefulWidget {

  final LocationPageViewModel viewModel;

  const Menu({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final padding = 16.0;
  var menuSize = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff6E4C30),
      ),
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: WidgetSize(
            onChange: (Size size) => setState(() => menuSize = min(size.height, size.width)),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: menuSize,
                maxHeight: menuSize,
              ),
              child: Column( children: [
                Expanded(flex: 2, child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: MenuButton(
                      onPressed: widget.viewModel.onQuestButtonPressed,
                      title: "Quest",
                      titleSize: 30,
                      svgPath: "assets/images/location_page/city_buttons/QuestButton.svg",
                      titleAngle: -0.23,
                    )),
                    Container(width: padding),
                    Expanded(flex: 1, child: MenuButton(
                      onPressed: widget.viewModel.onShopButtonPressed,
                      title: "Shop",
                      titleSize: 25,
                      svgPath: "assets/images/location_page/city_buttons/ShopButton.svg",
                      titleAngle: 0.23,
                    )),
                  ],
                ),),
                Container(height: padding),
                Expanded(flex: 1, child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: MenuButton(
                      onPressed: widget.viewModel.onCraftButtonPressed,
                      title: "Craft",
                      titleSize: 25,
                      svgPath: "assets/images/location_page/city_buttons/CraftButton.svg",
                      titleAngle: -0.23,
                    )),
                    Container(width: padding),
                    Expanded(flex: 1, child: MenuButton(
                      onPressed: widget.viewModel.onMapButtonPressed,
                      title: "Map",
                      titleSize: 20,
                      svgPath: "",
                      titleAngle: 0.23,
                    )),
                  ],
                ),),
              ],),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {

  final void Function() onPressed;
  final String title;
  final String svgPath;
  final double titleSize;
  final double titleAngle;

  const MenuButton({Key? key, required this.onPressed, required this.title, required this.svgPath, required this.titleSize, required this.titleAngle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var border = Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({MaterialState.pressed});
    var borderRadius = BorderRadius.circular(0.0);
    if(border is RoundedRectangleBorder){
      borderRadius = border.borderRadius.resolve(TextDirection.ltr);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(0.0))),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: SvgPicture.asset(
              svgPath,
              color: Color(0xffCE9248),
              width: 500,
              height: 500,
            ),

          ),
          Center(
            child: Transform.rotate(
              angle: titleAngle,
              child: Text(
                title,
                style: TextStyle(fontSize: titleSize),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      )
    );
  }
}
