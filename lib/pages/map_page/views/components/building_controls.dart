import 'package:flutter/material.dart';

import '../../view_model.dart';

class BuildingControls extends StatelessWidget {
  final MapPageViewModel viewModel;

  const BuildingControls({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: viewModel.onDeletePathSegmentButtonPressed,
            child: Icon(Icons.delete, color: Color(0xffffffff)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xffB41A1A)),
            )
          ),
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton(
            onPressed: viewModel.onFinishEditRouteButtonPressed,
            child: Icon(Icons.check, color: Color(0xffffffff)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff6E4C30)),
            )
          ),
        ],
      ),
    );
  }
}
