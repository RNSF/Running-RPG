import 'package:flutter/material.dart';
import '../../navigation_master_page/components/layer_gradient.dart';
import '../view_model.dart';
import 'components/location_info.dart';
import 'components/standard_controls.dart';

class StandardOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const StandardOverlay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LocationInfo(viewModel: viewModel),
      Expanded(flex: 1, child: Stack(
        children: [
          Column(children: [
            LayerGradient(),
            Expanded(flex: 1, child: SizedBox()),
            LayerGradient(isUp: true),
          ],),
          Column(children: [
            Expanded(child: SizedBox()),
            StandardControls(viewModel: viewModel),
          ],),
        ],
      ),)
    ],);
  }
}