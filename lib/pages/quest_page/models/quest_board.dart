import 'dart:math';

import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/choose_weighted.dart';
import 'package:running_game/map/components/hex_tile/structures/city_structure.dart';
import 'package:running_game/map/components/hex_tile_map.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';
import 'package:running_game/pages/quest_page/models/quest_generator.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';

import '../../../json_converters/vector2_json_converter.dart';

part "quest_board.g.dart";

@JsonSerializable()
class QuestBoard {
  final questLookbackTime = Duration(days: 14);
  final generateQuestEveryXHour = 24;
  final maxQuestCount = 4;


  final String locationName;
  final String description;
  final CityStats cityStats;
  @Vector2JsonConverter()
  final Vector2 mapCoordinates;

  DateTime? _lastGenerated;
  List<Quest> quests;

  QuestBoard({required this.mapCoordinates, this.locationName = "Mysterious Quest Board",
    this.cityStats = const CityStats(), this.quests = const [], this.description = "No Description for Quest Board"}){
    quests = quests.isEmpty ? [] : quests;
  }

  DateTime get lastGenerated => _lastGenerated ?? DateTime.now().subtract(questLookbackTime);
  set lastGenerated (n) => _lastGenerated = n;

  factory QuestBoard.fromJson(Map json) => _$QuestBoardFromJson(json);
  Map<String, dynamic> toJson() => _$QuestBoardToJson(this);

  void update(DateTime currentDateTime, HexTileMap hexTileMap, List<QuestGiverType> questGiverTypes){
    //Remove old quests
    for(var quest in <Quest>[... quests]){
      var timeSinceCreation = currentDateTime.difference(quest.creationDate);
      if(timeSinceCreation.compareTo(questLookbackTime) > 0){
        quests.remove(quest);
      }
    }

    //Generate new quests
    var questGenerator = QuestGenerator(hexTileMap: hexTileMap, questGiverTypes: questGiverTypes);

    currentDateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour);
    while(lastGenerated.isBefore(currentDateTime)){

      var seed = lastGenerated.difference(DateTime.fromMillisecondsSinceEpoch(0)).inHours;
      var rng = Random(seed);
      if(rng.nextInt(generateQuestEveryXHour) == 0){
        var randomNumber = rng.nextDouble();
        var totalWeight = 0.0;
        double? previousWeight;
        var weights = <double, double>{};
        //Choose range:
        difficultyDistribution.forEach((difficulty, weight) {
          if(previousWeight != null){
            var averageWeight = (weight+previousWeight!)/2;
            totalWeight += averageWeight;
            weights[difficulty] = averageWeight;
          }
          previousWeight = weight;
        });



        double targetDifficulty = chooseWeighted(weights);
        print(targetDifficulty);
        double? previousDifficulty;
        double? chosenDifficulty;
        difficultyDistribution.forEach((difficulty, weight) {
          if(targetDifficulty == difficulty){
            chosenDifficulty = getWeightedLineValue(rng.nextDouble(), previousDifficulty!, difficulty, previousWeight!, weight);
            return;
          }
          previousDifficulty = difficulty;
          previousWeight = weight;
        });
        print(chosenDifficulty);
        chosenDifficulty ??= 1.0;
        print("Quest Generated with difficulty: $chosenDifficulty");
        quests.add(questGenerator.generateQuest(cityStats, mapCoordinates, locationName, chosenDifficulty!, lastGenerated));

      };
      lastGenerated = lastGenerated.add(Duration(hours: 1));
    }
    if(quests.length > maxQuestCount){
      quests.removeRange(0, quests.length-maxQuestCount);
    }
  }

  //chooses a value between x1 and x2, where y1 and y2 are the weights at x1 and x2; r is roll
  double getWeightedLineValue(double r, double x1, double x2, double y1, double y2) {
    final m = (y2-y1)/(x2-x1);
    final b = y1-m*x1;
    final A = (x) {return 1/2*m*pow(x, 2) + b*x;};
    final p = A(x1);
    final q = A(x2);
    return (-b+sqrt(pow(b, 2)+2*m*((q-p)*r+p)))/m;
  }
}

final difficultyDistribution = <double, double>{
  1.0:	5,
  2.0:	80,
  3.0:	160,
  4.0:	200,
  5.0:	140,
  7.0:	45,
  16.0:	4,
  40.0:	1
};