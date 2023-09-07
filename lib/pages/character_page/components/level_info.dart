import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../map_page/views/components/standard_linear_progress_bar.dart';
import '../view_model.dart';



class LevelInfo extends StatelessWidget{
  final CharacterPageViewModel viewModel;

  LevelInfo({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff6E4C30),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 24.0,
          ),
          child: Column(
            children: [
              SizedBox(),
              Text(
                "Level ${viewModel.level}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              StandardLinearProgressBar(height: 26, width: 340, value: viewModel.levelProgress),
            ],
          ),
        ),
      ),
    );
  }
}