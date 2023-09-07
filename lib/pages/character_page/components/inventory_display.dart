import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:running_game/pages/character_page/view_model.dart';

import '../../../theme/theme_constants.dart';
import '../../../widget_size.dart';

class InventoryDisplay extends StatefulWidget {
  final CharacterPageViewModel viewModel;

  const InventoryDisplay({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<InventoryDisplay> createState() => _InventoryDisplayState();
}

class _InventoryDisplayState extends State<InventoryDisplay> {
  var menuSize = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        alignment: Alignment.center,
        color: Palette.background2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: WidgetSize(
            onChange: (Size size) => setState(() => menuSize = min(size.height, size.width)),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: menuSize,
                maxHeight: menuSize,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => widget.viewModel.onInventoryButtonPressed(index),
                      child: SvgPicture.asset(
                        "assets/images/character_page/player${index+1}.svg",
                      ),
                    ),
                  );
                })
              ),
            ),
          ),
        ),
      )
    );
  }
}
