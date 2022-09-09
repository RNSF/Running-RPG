import '../../../../theme/theme_constants.dart';
import '../../view_model.dart';
import "package:flutter/material.dart";

class StandardControls extends StatelessWidget{
  final MapPageViewModel viewModel;

  const StandardControls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: viewModel.onRecordButtonPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xffB41A1A)),
              foregroundColor: MaterialStateProperty.all<Color>(Palette.primary),
            ),
            child: Text(
              "Start Recording",
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton(
            onPressed: viewModel.onEditRouteButtonPressed,
            child: Icon(Icons.edit),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff6E4C30)),
              foregroundColor: MaterialStateProperty.all<Color>(Palette.primary),
            )
          ),
        ],
      ),
    );
  }
}