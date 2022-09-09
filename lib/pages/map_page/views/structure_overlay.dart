import 'package:flutter/material.dart';
import '../../navigation_master_page/components/layer_gradient.dart';
import '../view_model.dart';
import 'components/structure_info.dart';

class StructureOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const StructureOverlay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StructureInfo(viewModel: viewModel),
      LayerGradient(),
      Expanded(flex: 1, child: SizedBox()),
      LayerGradient(isUp: true),
    ],);
  }
}