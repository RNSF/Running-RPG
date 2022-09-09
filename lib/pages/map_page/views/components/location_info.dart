import "package:flutter/material.dart";
import 'package:running_game/pages/map_page/view_model.dart';

class LocationInfo extends StatelessWidget {

  final MapPageViewModel viewModel;

  const LocationInfo({Key? key, required this.viewModel}) : super(key: key);

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
          child: Row(
            children: [
              Expanded(flex: 1, child: SizedBox()),
              RichText(
                text: viewModel.cleanRouteLength > 0 ? TextSpan(
                  children: [
                    TextSpan(
                      text: "${viewModel.cleanRouteLength}km",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextSpan(
                      text: " from ",
                      style: (Theme.of(context).textTheme.headlineSmall)?.merge(TextStyle(fontWeight: FontWeight.normal)),
                    ),
                    TextSpan(
                      text: viewModel.targetLocationName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ]
                ) : TextSpan(
                  children: [
                    TextSpan(
                      text: "At ",
                      style: (Theme.of(context).textTheme.headlineSmall)?.merge(TextStyle(fontWeight: FontWeight.normal)),
                    ),
                    TextSpan(
                      text: viewModel.targetLocationName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ]
                ),
              ),
              Expanded(flex: 1, child: SizedBox()),
            ],
          )
        ),
      ),
    );
  }
}
