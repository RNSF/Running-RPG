import 'dart:math';

import 'package:flame/components.dart';
import 'package:running_game/choose_weighted.dart';
import 'package:running_game/map/components/hex_tile/hex_tile_type.dart';
import 'package:running_game/pages/quest_page/models/quest.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';

import '../../../map/components/hex_tile/structures/city_structure.dart';
import '../../../map/components/hex_tile_map.dart';

class QuestGenerator {
  final HexTileMap hexTileMap;
  var citySeed = 0.0;
  var questLookbackTime = Duration(days: 14);
  var questGivers = <QuestGiverType>[];

  QuestGenerator({required this.hexTileMap});

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

  Quest generateQuest(HexTileCity city, double difficulty){
    var questGiverType = chooseQuestGiverType(city.stats, difficulty);
    var questType = questGiverType.chooseQuestType(difficulty);

    var destinations = <QuestLocation>[];
    var possibleLocations = <QuestLocation, int>{};
    if(questType.isCity){
      var possibleCities = hexTileMap.getCitiesInRange(city.mapCoordinates, questType.minDistance, questType.maxDistance);
      possibleCities.forEach((city, distance) {possibleLocations[QuestLocation.fromHexTileCity(city)] = distance; });
    } else {
      var possibleNatures = hexTileMap.getNatureInRange(city.mapCoordinates, questType.minDistance, questType.maxDistance, questType.destinationTileTypes);
      possibleNatures.forEach((nature, distance) {
        var natureName = "";
        var possibleNames = questType.natureLocationNames[nature.type];
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
    var possibleLocationsRandomizer = List<QuestLocation>.from(possibleLocations.keys);
    possibleLocationsRandomizer.shuffle();
    destinations = possibleLocationsRandomizer.sublist(0, questType.destinationCount-1);

    var distance = 0.0;
    for(var destination in destinations){
      distance += possibleLocations[destination]!;
    }
    if(questType.mustReturn){
      distance += distance/destinations.length;
    }
    var difficultyCalculator = QuestDifficultyCalculator();
    var time = difficultyCalculator.calculateTime(difficulty, distance).clamp(questType.minTimeLimit, questType.maxTimeLimit).toDouble();
    difficulty = difficultyCalculator.calculateDifficulty(time, distance);
    return Quest(
      destinations: destinations,
      timeLimit: Duration(days: time.ceil(), hours: (time/24).ceil()%24),
      returnLocation: questType.mustReturn ? QuestLocation.fromHexTileCity(city) : null,
      xpReward: difficulty.round(),
      questGiver: questGiverType.generateQuestGiver(),
      descriptions: {QuestState.main : questType.generateDescription()},
      title: questType.generateTitle(),
    );
  }


  QuestGiverType chooseQuestGiverType(CityStats cityStats, double difficulty){
    var questGiverTypeScores = <QuestGiverType, double>{};
    for(var questGiverType in questGivers){
      questGiverTypeScores[questGiverType] = questGiverType.findQuestingPotential(difficulty, cityStats);
    }
    return chooseWeighted(questGiverTypeScores);
  }
  
}


class QuestDifficultyCalculator {
  double calculateTime(num difficulty, num distance) => pow(distance/difficulty, 2).toDouble();
  double calculateDifficulty(num time, num distance) => distance/sqrt(time);
  double calculateDistance(num difficulty, num time) => difficulty*pow(time, 2).toDouble();
}