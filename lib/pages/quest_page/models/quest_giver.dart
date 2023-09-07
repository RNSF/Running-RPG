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
  var type = "";
  var preferredCityStats = CityStats();
  var questTypes = <QuestType>[

  ];
  var possibleNames = <String>[

  ];

  QuestGiverType({
    this.type = "",
    this.preferredCityStats = const CityStats(),
    this.possibleNames = const []
  });

  double findQuestingPotential(double difficulty, CityStats cityStats){
    return findCityScore(cityStats)*findQuestScore(difficulty);
  }

  double findCityScore(CityStats cityStats){
    var cityScore = 0.0;
    var jsonPreferredCityStats = preferredCityStats.toJson();
    var jsonCityStats = cityStats.toJson();
    var nonZeroStatCount = 0;
    jsonPreferredCityStats.forEach((statName, value) {
      if(statName == "size"){
        value = 0.5;
      }
      cityScore += value*jsonCityStats[statName]!;
      if(value > 0.0){
        nonZeroStatCount++;
      }
    });
    return cityScore/nonZeroStatCount;
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
    print(questScores);
    return chooseWeighted(questScores);
  }

  QuestGiver generateQuestGiver(){
    return  QuestGiver(name: possibleNames.isNotEmpty? possibleNames[0] : "Mysterious Figure");
  }
}