import 'package:flutter/material.dart';
import '../../navigation_master_page/components/layer_gradient.dart';
import '../view_model.dart';
import 'components/recording_controls.dart';
import 'components/route_info.dart';

class RecordingOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const RecordingOverlay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RouteInfo(viewModel: viewModel),
      Expanded(flex: 1, child: Stack(
        children: [
          Column(children: [
            LayerGradient(),
            Expanded(flex: 1, child: SizedBox()),
            LayerGradient(isUp: true),
          ],),
          Column(children: [
            Expanded(child: SizedBox()),
            RecordingControls(viewModel: viewModel),
          ],),
        ],
      ),)
    ],);
  }
}