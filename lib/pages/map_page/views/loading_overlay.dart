import "package:flutter/material.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../view_model.dart';

class LoadingOverlay extends StatelessWidget {
  final MapPageViewModel viewModel;

  const LoadingOverlay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: SpinKitRotatingCircle(
          color: Colors.white,
          size: 40.0,
        )
      )
    );
  }
}
