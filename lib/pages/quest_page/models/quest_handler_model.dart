import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/pages/character_page/models/player_handler_model.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';
import 'package:running_game/pages/quest_page/models/quest_board.dart';
import 'package:running_game/pages/quest_page/models/quest_generator.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';
import 'package:running_game/saving_service/saving_service.dart';
import "package:running_game/json_converters/vector2_json_converter.dart";

import '../../../json_converters/json_loader.dart';
import '../../../locator.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';
import '../../../map/components/hex_tile_map.dart';
import '../../map_page/travel_event.dart';

part "quest_handler_model.g.dart";

@JsonSerializable()
class QuestHandlerModel {
  final maxActiveQuestCount = 4;
  final questLookbackTime = Duration(days: 14);
  final _controller = StreamController<QuestHandlerModel>.broadcast();
  @JsonKey(ignore: true)
  var questGiverTypes = <QuestGiverType>[];
  Map<int, Quest> activeQuests;
  Map<String, QuestBoard> questBoards;
  @JsonKey(ignore: true)
  Vector2 currentCoordinates = Vector2.zero();
  @JsonKey(ignore: true)
  Quest? _currentlyViewedQuest;
  @JsonKey(ignore: true)
  Stream<QuestHandlerModel> get stream => _controller.stream;
  @JsonKey(ignore: true)
  String? currentLocationName;
  @JsonKey(ignore: true)
  var pendingTravelEvents = <TravelEvent>[];

  QuestHandlerModel({
    this.activeQuests = const {},
    this.questBoards = const {},
  }){
    if(questBoards.isEmpty){
      questBoards = {};
    }
    activeQuests.forEach((localId, quest) {
      quest.localId = localId;
    });
   if(activeQuests.isEmpty){
     activeQuests = {};
   }
  }

  factory QuestHandlerModel.fromJson(Map json) => _$QuestHandlerModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuestHandlerModelToJson(this);

  List<Quest> get availableQuests => questBoards[currentLocationName]?.quests ?? [];

  set currentlyViewedQuest(Quest? n) {
    _currentlyViewedQuest = n;
    update(save: false);
  }

  @JsonKey(ignore: true)
  Quest? get currentlyViewedQuest => _currentlyViewedQuest;

  bool addActiveQuest(Quest quest, {int? localQuestId}){
    if(localQuestId == null){
      var availableLocalQuestIds = <int>[];
      for(var i=0; i<maxActiveQuestCount; i+=1){
        if(!activeQuests.keys.contains(i)){
          availableLocalQuestIds.add(i);
        }
      }
      if(availableLocalQuestIds.isEmpty){update(); return false;}
      availableLocalQuestIds.shuffle();
      localQuestId = availableLocalQuestIds.first;
    }
    activeQuests[localQuestId] = quest;
    quest.localId = localQuestId;
    update();
    return true;
  }

  void removeActiveQuest(int localQuestId){
    activeQuests.remove(localQuestId);
    update();
  }

  void removeAvailableQuest(int questBoardId){
    availableQuests.removeAt(questBoardId);
    update();
  }

  void onCoordinatesReached(Vector2 mapCoordinates, HexTileMap hexTileMap){


    currentLocationName = null;

    //Get current location name
    questBoards.forEach((locationName, questBoard) {
      if(questBoard.mapCoordinates == mapCoordinates && currentCoordinates != mapCoordinates){
        currentLocationName = locationName;
        pendingTravelEvents.add(TravelEvent(title: "You have arrived in ${questBoard.locationName}!", description: questBoard.description));
        questBoard.update(DateTime.now(), hexTileMap, questGiverTypes);

        return;
      }
    });

    currentCoordinates = mapCoordinates;

    for(var quest in activeQuests.values){
      var travelEvent = quest.coordinatesReached(mapCoordinates);
      if(travelEvent != null){
        pendingTravelEvents.add(travelEvent);
      }
    }






    update();
  }

  void questCompleted(int questId){
    var quest = activeQuests.remove(questId);
    locator.get<PlayerHandlerModel>().gainXp(quest?.xpReward ?? 0);
    update();
  }

  void update({bool save = true}){
    if(save){
      locator.get<SaveDataHandler>().updateMap(["game", "quests"], toJson(), override: true);
      locator.get<SaveDataHandler>().saveData();
    }
    _controller.sink.add(this);
    print("QUEST HANDLER UPDATED!");
  }


  void createQuestBoard(Vector2 mapCoordinates, String locationName, String locationDescription, CityStats cityStats){
    if(questBoards.keys.contains(locationName)){
      questBoards[locationName] = QuestBoard(mapCoordinates: mapCoordinates, locationName:  locationName, cityStats: cityStats, description:  locationDescription)
        ..quests = questBoards[locationName]?.quests ?? []
        ..lastGenerated = questBoards[locationName]?.lastGenerated ?? DateTime.now();
    } else {
      questBoards[locationName] = QuestBoard(mapCoordinates: mapCoordinates, locationName:  locationName, cityStats: cityStats, description:  locationDescription);
    }
  }


  Future<void> loadQuestGivers(BuildContext context) async {
    jsonToQuestGivers(
      (await JsonLoader().getJson(context, "assets/data/quest_data.json"))["data"],
      (await JsonLoader().getJson(context, "assets/data/quest_givers.json"))["data"]
    );
  }

  void jsonToQuestGivers(questDataJson, questGiverJson){
    //Generate quest giver types
    for(var questGiverData in questGiverJson){
      questGiverTypes.add(QuestGiverType(
        type: questGiverData["Type"] as String,
        possibleNames: <String>[... questGiverData["Names"]],
        preferredCityStats: CityStats.fromJson(questGiverData),
      ));
    }

    //Assign quest types to quest giver types
    for(var questTypeData in questDataJson){
      List<String> questGiverTypesForQuest = <String>[... questTypeData["Quest Giver"]];
      var questType = QuestType.fromJson(questTypeData);
      var canApplyToAny = questGiverTypesForQuest.contains("Any");
      questType.rarity /= canApplyToAny ? questGiverTypes.length : questGiverTypesForQuest.length;
      print("${questType.possibleTitles.first} RARITY: ${questType.rarity}");
      for(var questGiverType in questGiverTypes){
        if(questGiverTypesForQuest.contains(questGiverType.type) || canApplyToAny){
          questGiverType.questTypes.add(questType);
        }
      }
    }
    print("Quest Giver Types!!!: $questGiverTypes");

    //Remove quest givers which dont have any quests
    for(var questGiverType in <QuestGiverType>[... questGiverTypes]){
      print("Quest types from ${questGiverType.type}: ${questGiverType.questTypes}");
      if(questGiverType.questTypes.isEmpty){
        questGiverTypes.remove(questGiverType);
        print("Removed ${questGiverType.type}");
      }
    }
  }
}