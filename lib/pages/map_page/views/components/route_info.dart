import "package:flutter/material.dart";
import 'package:running_game/pages/map_page/views/components/standard_linear_progress_bar.dart';

import '../../view_model.dart';

class RouteInfo extends StatelessWidget{
  final MapPageViewModel viewModel;

  RouteInfo({required this.viewModel});

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
                "Route Progress",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              StandardLinearProgressBar(height: 26, width: 340, value: viewModel.routeProgress),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 28.0,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Travelling to",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.bodyMedium
                        ),
                        Text(
                          viewModel.targetLocationName,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${viewModel.cleanDistanceTravelled}/${viewModel.cleanRouteLength}",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              TextSpan(
                                text: " km",
                                style: Theme.of(context).textTheme.headlineSmall,
                              )
                            ]
                          )
                        )
                      ]
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}