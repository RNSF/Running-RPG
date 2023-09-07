// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_handler_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestHandlerModel _$QuestHandlerModelFromJson(Map json) => QuestHandlerModel(
      activeQuests: (json['activeQuests'] as Map?)?.map(
            (k, e) =>
                MapEntry(int.parse(k as String), Quest.fromJson(e as Map)),
          ) ??
          const {},
      questBoards: (json['questBoards'] as Map?)?.map(
            (k, e) => MapEntry(k as String, QuestBoard.fromJson(e as Map)),
          ) ??
          const {},
    );

Map<String, dynamic> _$QuestHandlerModelToJson(QuestHandlerModel instance) =>
    <String, dynamic>{
      'activeQuests': instance.activeQuests
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'questBoards':
          instance.questBoards.map((k, e) => MapEntry(k, e.toJson())),
    };
