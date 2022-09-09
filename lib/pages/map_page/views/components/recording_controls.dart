import 'package:flutter/material.dart';
import 'package:running_game/pages/map_page/view_model.dart';

import '../../../../theme/theme_constants.dart';

class RecordingControls extends StatelessWidget {
  final MapPageViewModel viewModel;

  const RecordingControls({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton.icon(
            onPressed: viewModel.onFinishRecordButtonPressed,
            label: Text(
              "Finish Recording",
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xffffffff)),
              foregroundColor: MaterialStateProperty.all<Color>(Palette.accent),
            ),
            icon: Icon(Icons.fiber_manual_record)
          ),
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton(onPressed: () {
            viewModel.travel(0.1);
          }, child: Icon(Icons.arrow_right))
        ],
      ),
    );
  }
}
