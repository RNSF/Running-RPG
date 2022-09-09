
import "package:flutter/material.dart";
import 'package:running_game/pages/map_page/view_model.dart';
import "package:flutter_svg/flutter_svg.dart";

class StructureInfo extends StatelessWidget {

  final MapPageViewModel viewModel;

  const StructureInfo({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var questMarkers = viewModel.selectedStructureQuestMarkers;
    var currentQuests = viewModel.currentQuests;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xff6E4C30),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 24.0,
          ),
          child: Column(children: [
            Text(viewModel.selectedStructureName, style: Theme.of(context).textTheme.headlineSmall),
            Text(viewModel.selectedStructureDescription, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.left,),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: questMarkers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var questMarker = questMarkers[index];
                return Row(children: [
                  SvgPicture.asset(
                    questMarker.bannerPath,
                    width: 20,
                    height: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currentQuests[questMarker.localQuestId]?.title ?? "Untitled Quest",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],);
              }
            )
          ],)
        ),
      ),
    );
  }
}
