import 'package:flutter/material.dart';

class LayerGradient extends StatelessWidget {
  final double height;
  final double darkness;
  final bool isUp;

  const LayerGradient({Key? key, this.height = 75.0, this.darkness = 0.2, this.isUp = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var colors = <Color>[Colors.black.withOpacity(darkness), Colors.black.withOpacity(0)];
    if(isUp){colors = colors.reversed.toList();}



    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      )
    );
  }
}
