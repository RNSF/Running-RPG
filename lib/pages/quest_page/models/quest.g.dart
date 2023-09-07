// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quest _$QuestFromJson(Map json) => Quest(
      creationDate: DateTime.parse(json['creationDate'] as String),
      destinations: (json['destinations'] as List<dynamic>?)
              ?.map((e) => QuestLocation.fromJson(e as Map))
              .toList() ??
          const [],
      timeLimit: json['timeLimit'] == null
          ? const Duration(days: 1)
          : Duration(microseconds: json['timeLimit'] as int),
      returnLocation: json['returnLocation'] == null
          ? null
          : QuestLocation.fromJson(json['returnLocation'] as Map),
      xpReward: json['xpReward'] as int? ?? 300,
      questGiver: json['questGiver'] == null
          ? const QuestGiver()
          : QuestGiver.fromJson(json['questGiver'] as Map),
      descriptions: (json['descriptions'] as Map?)?.map(
            (k, e) =>
                MapEntry($enumDecode(_$QuestStateEnumMap, k), e as String),
          ) ??
          const {},
      title: json['title'] as String? ?? "Unnamed Quest",
      localId: json['localId'] as int?,
    )
      ..reachedDestinations = (json['reachedDestinations'] as List<dynamic>)
          .map((e) => QuestLocation.fromJson(e as Map))
          .toList()
      ..state = $enumDecode(_$QuestStateEnumMap, json['state'])
      ..startTime = json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String);

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'timeLimit': instance.timeLimit.inMicroseconds,
      'destinations': instance.destinations.map((e) => e.toJson()).toList(),
      'xpReward': instance.xpReward,
      'returnLocation': instance.returnLocation?.toJson(),
      'questGiver': instance.questGiver.toJson(),
      'descriptions': instance.descriptions
          .map((k, e) => MapEntry(_$QuestStateEnumMap[k]!, e)),
      'title': instance.title,
      'creationDate': instance.creationDate.toIso8601String(),
      'reachedDestinations':
          instance.reachedDestinations.map((e) => e.toJson()).toList(),
      'state': _$QuestStateEnumMap[instance.state]!,
      'localId': instance.localId,
      'startTime': instance.startTime?.toIso8601String(),
    };

const _$QuestStateEnumMap = {
  QuestState.main: 'main',
  QuestState.destinationReached: 'destinationReached',
  QuestState.comeBack: 'comeBack',
  QuestState.rewardPending: 'rewardPending',
};
