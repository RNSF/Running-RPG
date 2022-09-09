import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';

import '../../../choose_weighted.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';

part "quest_giver.g.dart";

@JsonSerializable()
class QuestGiver {
  final String name;

  const QuestGiver({this.name = "Unnamed Quest Giver"});

  factory QuestGiver.fromJson(Map json) => _$QuestGiverFromJson(json);
  Map<String, dynamic> toJson() => _$QuestGiverToJson(this);
}

class QuestGiverType {
  var preferredCityStats = CityStats();
  var questTypes = <QuestType>[

  ];
  var possibleNames = <String>[

  ];

  double findQuestingPotential(double difficulty, CityStats cityStats){
    return findCityScore(cityStats)*findQuestScore(difficulty);
  }

  double findCityScore(CityStats cityStats){
    var cityScore = 0.0;
    var jsonPreferredCityStats = preferredCityStats.toJson();
    var jsonCityStats = cityStats.toJson();
    jsonPreferredCityStats.forEach((statName, value) {
      cityScore += value*jsonCityStats[statName]!;
    });
    return cityScore;
  }

  double findQuestScore(double difficulty){
    var questScore = 0.0;
    for(var questType in questTypes){
      questScore += questType.findIdealness(difficulty);
    }
    return questScore;
  }

  QuestType chooseQuestType(double difficulty){
    var questScores = <QuestType, double>{};
    for(var questType in questTypes){
      questScores[questType] = questType.findIdealness(difficulty);
    }
    return chooseWeighted(questScores);
  }

  QuestGiver generateQuestGiver(){
    return  QuestGiver(name: possibleNames.isNotEmpty? possibleNames[0] : "Mysterious Figure");
  }
}