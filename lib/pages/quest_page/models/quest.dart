import 'dart:math';

import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/pages/quest_page/models/quest_generator.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';

import '../../../map/components/hex_tile/hex_tile_type.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';

part "quest.g.dart";

enum QuestState{
  main,
  comeBack,
  rewardPending,
}

@JsonSerializable()
class Quest {

  final Duration timeLimit;
  final List<QuestLocation> destinations;
  final int xpReward;
  final QuestLocation? returnLocation;
  final QuestGiver questGiver;
  final Map<QuestState, String> descriptions;
  final String title;
  var reachedDestinations = <QuestLocation>[];
  var state = QuestState.main;
  int? localId;
  DateTime? startTime;

  Quest({this.destinations = const [], this.timeLimit = const Duration(days: 1), this.returnLocation, this.xpReward = 300, this.questGiver = const QuestGiver(), this.descriptions = const {}, this.title = "Unnamed Quest", this.localId});

  factory Quest.fromJson(Map json) => _$QuestFromJson(json);
  Map<String, dynamic> toJson() => _$QuestToJson(this);

  DateTime? get endTime => startTime?.add(timeLimit);


  Duration get remainingTime {
    if(endTime != null){
      return DateTime.now().difference(endTime!);
    } else {
      return timeLimit;
    }
  }

  List<QuestLocation> get unreachedDestinations {
    var unreached = List<QuestLocation>.from(destinations);
    unreached.removeWhere((element) => reachedDestinations.contains(element));
    return unreached;
  }

  String get description => descriptions[state] ?? "No description";

  void coordinatesReached(Vector2 mapCoordinates) {
    for(var destination in destinations){
      if(destination.mapCoordinates == mapCoordinates){
        reachedDestinations.add(destination);
      }
    }
    updateState(mapCoordinates);
  }

  void updateState(Vector2 mapCoordinates) {
    if(unreachedDestinations.isEmpty){
      state = QuestState.comeBack;
    } else if(returnLocation == null) {
      state = QuestState.rewardPending;
    } else if(returnLocation!.mapCoordinates == mapCoordinates){
      state = QuestState.rewardPending;
    } else {
      state = QuestState.main;
    }
  }

  get descriptionsJson {
    var map = <String, String>{};
    descriptions.forEach((questState, description) {
      map[<QuestState, String>{
        QuestState.main : "main",
        QuestState.rewardPending : "reward_pending",
        QuestState.comeBack : "values",
      }[questState] ?? ""] = description;
    });
    QuestState.main.toString();
  }
}


class QuestType{
  final int minDistance;
  final int maxDistance;
  final bool isCity;
  final bool mustReturn;
  final int minDestinationCount;
  final int maxDestinationCount;
  final List<HexTileType>? destinationTileTypes;
  final CityStats preferredCityStats;
  final int minTimeLimit;
  final int maxTimeLimit;
  final double rarity;
  final Map<HexTileType, List<String>> natureLocationNames;
  final List<String> possibleDescriptions;
  final List<String> possibleTitles;

  late int destinationCount;

  QuestType({
    this.minDistance = 2,
    this.maxDistance = 4,
    this.isCity = false,
    this.mustReturn = true,
    this.minDestinationCount = 1,
    this.maxDestinationCount = 1,
    this.minTimeLimit = 2,
    this.maxTimeLimit = 4,
    this.preferredCityStats = const CityStats(),
    this.rarity = 1.0,
    this.natureLocationNames = const {},
    this.destinationTileTypes = const [],
    this.possibleDescriptions = const [],
    this.possibleTitles = const []
  }) {
    chooseDestinationCount();
  }

  double get estimatedMinDifficulty {
    return QuestDifficultyCalculator().calculateDifficulty(maxTimeLimit, minDistance*(destinationCount+(mustReturn ? 1.0 : 0.0)));
  }

  double get estimatedMaxDifficulty {
    return QuestDifficultyCalculator().calculateDifficulty(minTimeLimit, maxDistance*(destinationCount+(mustReturn ? 1.0 : 0.0)));
  }

  double findIdealness(double difficulty){
    var minDifficulty = estimatedMinDifficulty;
    var maxDifficulty = estimatedMaxDifficulty;
    var avgDifficulty = (maxDifficulty + minDifficulty)/2;
    var difficultyRange = (maxDifficulty - minDifficulty);
    return max(0, -(((difficulty-avgDifficulty)/(difficultyRange/2)).abs()) + 1 )*rarity;
  }

  void chooseDestinationCount(){
    var rng = Random();
    destinationCount = rng.nextInt(maxDestinationCount - minDestinationCount) + minDestinationCount;
  }

  String generateDescription(){
    possibleDescriptions.shuffle();
    return possibleDescriptions.isNotEmpty ? possibleDescriptions[0] : "A very strange quest";
  }

  String generateTitle(){
    possibleTitles.shuffle();
    return possibleTitles.isNotEmpty ? possibleTitles[0] : "Mystery Quest";
  }
}
