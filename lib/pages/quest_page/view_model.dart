import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_game/pages/quest_page/models/quest_handler_model.dart';

import '../../locator.dart';
import '../navigation_master_page/remote_controller_model.dart';
import 'models/quest.dart';
import 'models/quest_generator.dart';
import 'models/quest_giver.dart';
import 'models/quest_location.dart';

class QuestPageViewModel extends ChangeNotifier {
  final questHandler = locator.get<QuestHandlerModel>();
  final remoteNavigationController = locator.get<RemoteNavigationControllerModel>();
  late StreamSubscription questHandlerSubscription;
  var currentQuests = <QuestDisplay>[];
  var availableQuests = <QuestDisplay>[];

  QuestPageViewModel(BuildContext context) {
    questHandlerSubscription = questHandler.stream.listen(
      onQuestHandlerUpdate
    );
    onQuestHandlerUpdate(questHandler);
  }

  int? selectedCurrentQuestIndex;
  int? selectedAvailableQuestIndex;

  bool get canGetMoreQuests => questHandler.activeQuests.length < questHandler.maxActiveQuestCount;

  void onQuestHandlerUpdate(QuestHandlerModel _){
    for(var quest in questHandler.activeQuests.values){
      var hasQuest = false;
      for(var currentQuest in currentQuests){
        if(currentQuest.quest == quest){
          hasQuest = true;
          break;
        }
      }
      if(!hasQuest){
        currentQuests.add(QuestDisplay(quest: quest));
      }
    }
    for(var currentQuest in List.from(currentQuests)){
      if(!questHandler.activeQuests.values.contains(currentQuest.quest)){
        currentQuests.remove(currentQuest);
      }
    }
    print("AVAILABLE QUESTS: ${questHandler.availableQuests}");

    for(var quest in questHandler.availableQuests){
      var hasQuest = false;
      for(var availableQuest in availableQuests){
        if(availableQuest.quest == quest){
          hasQuest = true;
          break;
        }
      }
      if(!hasQuest){
        availableQuests.add(QuestDisplay(quest: quest));
      }
    }
    for(var currentQuest in List.from(availableQuests)){
      if(!questHandler.availableQuests.contains(currentQuest.quest)){
        availableQuests.remove(currentQuest);
      }
    }
  }


  void onCurrentQuestRemoved(int index){
    var questId = currentQuests[index].quest.localId;
    if(questId != null){
      questHandler.removeActiveQuest(questId);
      selectedCurrentQuestIndex = selectedCurrentQuestIndex == index ? null : index;
      notifyListeners();
    }
  }

  void onAvailableQuestAdded(int index){
    var questView = availableQuests.removeAt(index);
    questHandler.addActiveQuest(questView.quest);
    questHandler.removeAvailableQuest(index);
    selectedAvailableQuestIndex = selectedAvailableQuestIndex == index ? null : index;
    notifyListeners();
  }

  void onCurrentQuestCardTapped(int index){
    selectedCurrentQuestIndex = selectedCurrentQuestIndex == index ? null : index;
    selectedAvailableQuestIndex = null;
    notifyListeners();
  }

  void onAvailableQuestCardTapped(int index){
    selectedAvailableQuestIndex = selectedAvailableQuestIndex == index ? null : index;
    selectedCurrentQuestIndex = null;
    notifyListeners();
  }

  void onQuestRewardClaimed(int index){
    questHandler.questCompleted(index);
    remoteNavigationController.queueSwitch("Character");
  }


  void onQuestHelpRequested(BuildContext context, int index, bool isCurrentQuest) async {
    var quest = isCurrentQuest ? currentQuests[index].quest : availableQuests[index].quest;
    questHandler.currentlyViewedQuest = quest;
    remoteNavigationController.queueSwitch("Map");
    Navigator.pop(context);
    //await Navigator.of(context).pushNamed("/map_page");
    //questHandler.currentlyViewedQuest = null;
  }

}




class QuestDisplay {
  final Quest quest;

  const QuestDisplay({required this.quest});

  String get cleanXpReward => "${quest.xpReward.round()} XP";
  String get cleanRemainingTime {
    var time = quest.remainingTime;
    if(time.inDays > 0){return "${time.inDays} Days";}
    if(time.inHours > 0){return "${time.inHours} Hours";}
    return "${time.inMinutes} Mins";
  }
  String get cleanDestinations {
    var text = "";
    for(var destination in quest.destinations){
      text += "${destination.name}, ";
    }
    return text.substring(0, text.length-2);
  }
  String get description => quest.description;
  String get title => quest.title;
  String get questGiver => quest.questGiver.name;
  int get localQuestId => (quest.localId ?? 0);
  bool get isCompleted => quest.state == QuestState.rewardPending;
}

