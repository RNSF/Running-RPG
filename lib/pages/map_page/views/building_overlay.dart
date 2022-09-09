import 'package:flutter/material.dart';
import '../../navigation_master_page/components/layer_gradient.dart';
import '../view_model.dart';
import 'components/building_controls.dart';

class BuildingOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const BuildingOverlay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        Expanded(flex: 1, child: SizedBox()),
        LayerGradient(isUp: true),
      ],),
      Column(children: [
        Expanded(child: SizedBox()),
        BuildingControls(viewModel: viewModel),
      ],),
    ]);
  }
}