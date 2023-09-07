import 'dart:math';

import 'package:flame/components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:running_game/pages/quest_page/models/quest_generator.dart';
import 'package:running_game/pages/quest_page/models/quest_giver.dart';
import 'package:running_game/pages/quest_page/models/quest_location.dart';

import '../../../map/components/hex_tile/hex_tile_type.dart';
import '../../../map/components/hex_tile/structures/city_structure.dart';
import '../../map_page/travel_event.dart';

part "quest.g.dart";

enum QuestState{
  main,
  destinationReached,
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
  final DateTime creationDate;
  var reachedDestinations = <QuestLocation>[];
  var state = QuestState.main;
  int? localId;
  DateTime? startTime;

  Quest({required this.creationDate, this.destinations = const [], this.timeLimit = const Duration(days: 1), this.returnLocation, this.xpReward = 300, this.questGiver = const QuestGiver(), this.descriptions = const {}, this.title = "Unnamed Quest", this.localId});

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

  List<QuestLocation> get questMarkerLocation {
    var unreached = List<QuestLocation>.from(unreachedDestinations);
    if(unreached.isEmpty && returnLocation != null){
      unreached.add(returnLocation!);
    } return unreached;
  }

  String get description => descriptions[state] ?? "No description";

  TravelEvent? coordinatesReached(Vector2 mapCoordinates) {
    TravelEvent? travelEvent;
    for(var destination in unreachedDestinations){
      if(destination.mapCoordinates == mapCoordinates){
        reachedDestinations.add(destination);
        travelEvent = TravelEvent(title: "Quest Updated!", description: descriptions[QuestState.destinationReached] ?? "No description :(");
      }
    }
    updateState(mapCoordinates);
    return travelEvent; //return true if reached a destination for the quest
  }

  void updateState(Vector2 mapCoordinates) {
    if(unreachedDestinations.isNotEmpty){
      state = QuestState.main;
    } else if(returnLocation == null) {
      state = QuestState.rewardPending;
    } else if(returnLocation!.mapCoordinates == mapCoordinates){
      state = QuestState.rewardPending;
    } else {
      state = QuestState.comeBack;
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
  static const int cityMultiplier = 12;
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
  double rarity;
  final List<String> natureLocationNames;
  final Map<QuestState, List<String>> possibleDescriptions;
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
    this.natureLocationNames = const [],
    this.destinationTileTypes = const [],
    this.possibleDescriptions = const {},
    this.possibleTitles = const []
  }) {
    chooseDestinationCount();
  }

  factory QuestType.fromJson(Map<String, dynamic> json) {
    return QuestType(
      minDistance: json["Min Distance"],
      maxDistance: json["Max Distance"],
      isCity: json["Is City"],
      mustReturn:  json["Return"],
      minDestinationCount: json["Min Destination Count"],
      maxDestinationCount: json["Max Destination Count"],
      minTimeLimit: json["Min Time"],
      maxTimeLimit: json["Max Time"],
      rarity: json["Rarity"],
      natureLocationNames: <String>[... json["Nature Location Names"]],
      destinationTileTypes: <HexTileType>[... <String>[... json["Destination Tile Types"]].map(StringToHexTileType)],
      possibleDescriptions: <QuestState, List<String>>{
        QuestState.main: [json["Start Text"]],
        QuestState.rewardPending: [json["End Text"]],
        QuestState.destinationReached: [json["Location Text"]],
        QuestState.comeBack: [json["Return Text"]],
      },
      possibleTitles: <String>[... json["Titles"]],
      preferredCityStats: CityStats.fromStringList(<String>[... json["Preferred City Stats"]]),
    );
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
    return (difficulty <= maxDifficulty && difficulty >= minDifficulty) ? rarity : 0.0;
    //return max(0, -(((difficulty-avgDifficulty)/(difficultyRange/2)).abs()) + 1 )*rarity*(isCity ? cityMultiplier : 1.0);
  }

  void chooseDestinationCount(){
    var rng = Random();
    destinationCount = rng.nextInt(maxDestinationCount - minDestinationCount + 1) + minDestinationCount;
  }

  Map<QuestState, String> generateDescriptions(){
    var descriptions = <QuestState, String>{};
    possibleDescriptions.forEach((questState, options) {
      options.shuffle();
      descriptions[questState] = options.isNotEmpty ? options[0] : "A very strange quest";
    });
    return descriptions;
  }

  String generateTitle(){
    possibleTitles.shuffle();
    return possibleTitles.isNotEmpty ? possibleTitles[0] : "Mystery Quest";
  }
}
