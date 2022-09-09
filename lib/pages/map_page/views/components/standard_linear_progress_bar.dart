import "package:flutter/material.dart";

class StandardLinearProgressBar extends StatelessWidget{

  double value;
  double height;
  double width;

  StandardLinearProgressBar({this.value = 0, this.height = 20.0, this.width = 300.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height/2),
        border: Border.all(color: Color(0xffE3E3E3), width: 3)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(height/2)),
        child: LinearProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffB41A1A)),
          backgroundColor: Color(0xffffffff),
        )
      )
    );
  }
}