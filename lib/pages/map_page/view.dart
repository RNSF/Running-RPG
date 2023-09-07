import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_game/pages/map_page/view_model.dart';
import 'package:running_game/pages/map_page/views/building_overlay.dart';
import 'package:running_game/pages/map_page/views/event_overlay.dart';
import 'package:running_game/pages/map_page/views/loading_overlay.dart';
import 'package:running_game/pages/map_page/views/recording_overlay.dart';
import 'package:running_game/pages/map_page/views/standard_overlay.dart';
import 'package:running_game/pages/map_page/views/structure_overlay.dart';

import '../../widget_size.dart';

class MapPage extends StatefulWidget  {

  const MapPage();

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin  {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var viewModel = MapPageViewModel(context: context);
    //var viewModel = Provider.of<MapPageViewModel>(context);
    return Stack(
      children: [
        WidgetSize(
          onChange: viewModel.onGameMapSizeChange,
          child: viewModel.gameMap != null ? GameWidget(game: viewModel.gameMap!) : Container(),
        ),
        ChangeNotifierProvider<MapPageViewModel>(
          create: (context) => viewModel,
          builder: (context, _) {
            viewModel = Provider.of<MapPageViewModel>(context);
            switch(viewModel.mapState){
              case MapState.standard: return StandardOverlay(viewModel: viewModel);
              case MapState.building: return BuildingOverlay(viewModel: viewModel);
              case MapState.recording: return RecordingOverlay(viewModel: viewModel);
              case MapState.loading: return LoadingOverlay(viewModel: viewModel);
              case MapState.structureView : return StructureOverlay(viewModel: viewModel);
              case MapState.eventOverview : return EventOverlay(viewModel: viewModel);
            }
            return Container();
          }
        ),
      ],
    );
  }
}





