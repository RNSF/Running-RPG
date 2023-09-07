import 'package:flutter/material.dart';
import '../../navigation_master_page/components/layer_gradient.dart';
import '../view_model.dart';
import 'components/location_info.dart';
import 'components/standard_controls.dart';

class EventOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const EventOverlay({Key? key, required this.viewModel}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_){

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(viewModel.currentEvent?.title ?? "No title"),
          content: Text(viewModel.currentEvent?.description ?? "No description"),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.onCloseEventButtonPressed();
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
            !viewModel.isLastEvent ? TextButton(
              onPressed: () {
                viewModel.onNextEventButtonPressed();
                Navigator.pop(context);
              },
              child: Text("Next"),
            ) : Container(),
          ]
        )
      );

    });

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
          ],),
        ],
      ),)
    ],);
  }


}