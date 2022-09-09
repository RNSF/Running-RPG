import 'dart:async';

import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/pages/character_page/models/player_handler_model.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';
import 'package:running_game/saving_service/saving_service.dart';

import '../../../locator.dart';

part "quest_handler_model.g.dart";

@JsonSerializable()
class QuestHandlerModel {
  final maxActiveQuestCount = 4;
  final questLookbackTime = Duration(days: 14);
  final _controller = StreamController<QuestHandlerModel>.broadcast();
  Map<int, Quest> activeQuests;
  Map<int, Quest> rejectedQuests;
  @JsonKey(ignore: true)
  Quest? _currentlyViewedQuest;
  Stream<QuestHandlerModel> get stream => _controller.stream;

  QuestHandlerModel({
    this.activeQuests = const {},
    this.rejectedQuests = const {},
  }){
   if(activeQuests.isEmpty){
     activeQuests = {0: Quest(
      destinations: [QuestLocation(mapCoordinates: Vector2.zero(), name: "Sunhaven")],
      returnLocation: QuestLocation(mapCoordinates: Vector2.zero(), name: "IDK"),
      timeLimit: Duration(days: 3),
      xpReward: 400,
      questGiver: QuestGiver(name: "Sir Brickston"),
      descriptions: {QuestState.main: "[person]'s pickaxe broke a few days ago, and he needs it repaired. Bring it back within [timeLimit] for a handsome reward."},
      title: "Amazing Quest 1!",
      localId: 0,
    ),
    1: Quest(
      destinations: [QuestLocation(mapCoordinates: Vector2.zero(), name: "Sunhaven")],
      returnLocation: QuestLocation(mapCoordinates: Vector2.zero(), name: "IDK"),
      timeLimit: Duration(hours: 13, days: 0),
      xpReward: 600,
      questGiver: QuestGiver(name: "Sir Brickston"),
      descriptions: {QuestState.main: "[person]'s pickaxe broke a few days ago, and he needs it repaired. Bring it back within [timeLimit] for a handsome reward."},
      title: "Amazing Quest 2!",
      localId: 1,
    ),};
   }
   if(rejectedQuests.isEmpty){
     rejectedQuests = {0: Quest(
      destinations: [QuestLocation(mapCoordinates: Vector2.zero(), name: "Sunhaven")],
      returnLocation: QuestLocation(mapCoordinates: Vector2.zero(), name: "IDK"),
      timeLimit: Duration(days: 3),
      xpReward: 400,
      questGiver: QuestGiver(name: "Sir Brickston"),
      descriptions: {QuestState.main: "[person]'s pickaxe broke a few days ago, and he needs it repaired. Bring it back within [timeLimit] for a handsome reward."},
      title: "Amazing Quest 1!",
      localId: 0,
    ),
    1: Quest(
      destinations: [QuestLocation(mapCoordinates: Vector2.zero(), name: "Sunhaven")],
      returnLocation: QuestLocation(mapCoordinates: Vector2.zero(), name: "IDK"),
      timeLimit: Duration(hours: 13, days: 0),
      xpReward: 600,
      questGiver: QuestGiver(name: "Sir Brickston"),
      descriptions: {QuestState.main: "[person]'s pickaxe broke a few days ago, and he needs it repaired. Bring it back within [timeLimit] for a handsome reward."},
      title: "Amazing Quest 2!",
      localId: 1,
    ),};
   }
  }

  factory QuestHandlerModel.fromJson(Map json) => _$QuestHandlerModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuestHandlerModelToJson(this);

  set currentlyViewedQuest(Quest? n) {
    _currentlyViewedQuest = n;
    update(save: false);
  }

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

  void addRejectedQuest(dateTime, questId){
    rejectedQuests[dateTime] = questId;
    update();
  }

  void onCoordinatesReached(Vector2 mapCoordinates){
    for(var quest in activeQuests.values){
      quest.coordinatesReached(mapCoordinates);
    }
  }

  void questCompleted(int questId){
    var quest = activeQuests.remove(questId);
    locator.get<PlayerHandlerModel>().gainXp(quest?.xpReward ?? 0);
  }

  void update({bool save = true}){
    if(save){
      locator.get<SaveDataHandler>().updateMap(["game", "quests"], toJson(), override: true);
      locator.get<SaveDataHandler>().saveData();
    }
    _controller.sink.add(this);
  }
}