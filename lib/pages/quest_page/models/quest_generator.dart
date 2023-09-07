import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_game/choose_weighted.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_type.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';

import '../../../json_converters/json_loader.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';
import '../../../map/components/hex_tile_map.dart';

class QuestGenerator {
  final HexTileMap hexTileMap;
  final List<QuestGiverType> questGiverTypes;
  var citySeed = 0.0;
  var questLookbackTime = Duration(days: 14);


  QuestGenerator({required this.hexTileMap, required this.questGiverTypes});



  /*
  List<Quest> getQuests(HexTileCity city, DateTime currentDateTime){
    currentDateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour)
    var dateTime = currentDateTime.subtract(questLookbackTime);
    while(dateTime.isBefore(currentDateTime)){
      var seed = dateTime.difference(DateTime.fromMillisecondsSinceEpoch(0)).inHours;
      var rng = Random(seed);
      rng.
      dateTime.add(Duration(hours: 1));
    }

  }

   */

  Quest generateQuest(CityStats cityStats, Vector2 startingMapCoordinates, String startingLocationName, double difficulty, DateTime generationDate){

    QuestGiverType? questGiverType;
    QuestType? questType;
    var destinations = <QuestLocation>[];
    var distance = 0.0;
    while(destinations.isEmpty){
      //Choose quest giver
      questGiverType = chooseQuestGiverType(cityStats, difficulty);

      //Choose quest type based on quest giver + difficulty
      questType = questGiverType.chooseQuestType(difficulty);
      //Choose destinations

      var possibleLocations = <QuestLocation, int>{};
      print("Generating Quest ${questType.possibleTitles.first}");
      if(questType.isCity){
        var possibleCities = hexTileMap.getCitiesInRange(startingMapCoordinates, questType.minDistance, questType.maxDistance);
        possibleCities.forEach((city, distance) {possibleLocations[QuestLocation.fromHexTileCity(city)] = distance; });

      } else {
        var possibleNatures = hexTileMap.getNatureInRange(startingMapCoordinates, questType.minDistance, questType.maxDistance, questType.destinationTileTypes);
        possibleNatures.forEach((nature, distance) {
          var natureName = "";
          var possibleNames = questType!.natureLocationNames;
          if(possibleNames != null){
            var rng = Random();
            natureName = possibleNames[rng.nextInt(possibleNames.length)];
          }

          possibleLocations[QuestLocation(
            mapCoordinates: nature.tilePosition,
            name: natureName
          )] = distance;
        });
      }
      print("CITIES IN RANGE: $possibleLocations");
      var possibleLocationsRandomizer = List<QuestLocation>.from(possibleLocations.keys);
      possibleLocationsRandomizer.shuffle();
      if(possibleLocationsRandomizer.length >= questType.destinationCount){
        destinations = possibleLocationsRandomizer.sublist(0, questType.destinationCount);
      } else {
        print("CITIES IN RANGE: $possibleLocations");
        continue;
      }
      distance = 0.0;
      for(var destination in destinations){
        distance += possibleLocations[destination]!;
      }
      if(questType.mustReturn){
        distance += distance/destinations.length;
      }
      print("GOING WITH QUEST: ${questType.possibleTitles.first}");
      print(destinations);
    }


    var difficultyCalculator = QuestDifficultyCalculator();
    var time = difficultyCalculator.calculateTime(difficulty, distance).clamp(questType!.minTimeLimit, questType.maxTimeLimit).toDouble();
    difficulty = difficultyCalculator.calculateDifficulty(time, distance);
    return Quest(
      creationDate: generationDate,
      destinations: destinations,
      timeLimit: Duration(days: time.floor(), hours: (time/24).floor()%24),
      returnLocation: questType.mustReturn ? QuestLocation(mapCoordinates: startingMapCoordinates, name: startingLocationName) : null,
      xpReward: difficulty.round()*10,
      questGiver: questGiverType!.generateQuestGiver(),
      descriptions: questType.generateDescriptions(),
      title: questType.generateTitle(),
    );
  }


  QuestGiverType chooseQuestGiverType(CityStats cityStats, double difficulty){
    var questGiverTypeScores = <QuestGiverType, double>{};
    for(var questGiverType in questGiverTypes){
      questGiverTypeScores[questGiverType] = questGiverType.findQuestingPotential(difficulty, cityStats);
    }
    print(questGiverTypeScores.map((key, value) => MapEntry(key.possibleNames.first, (value*10000).toInt())));
    return chooseWeighted(questGiverTypeScores);
  }
  
}


class QuestDifficultyCalculator {
  double calculateTime(num difficulty, num distance) => pow(distance/difficulty, 2).toDouble();
  double calculateDifficulty(num time, num distance) => distance/sqrt(time);
  double calculateDistance(num difficulty, num time) => difficulty*pow(time, 2).toDouble();
}