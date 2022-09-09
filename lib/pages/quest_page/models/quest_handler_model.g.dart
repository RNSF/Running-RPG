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
      rejectedQuests: (json['rejectedQuests'] as Map?)?.map(
            (k, e) =>
                MapEntry(int.parse(k as String), Quest.fromJson(e as Map)),
          ) ??
          const {},
    )..currentlyViewedQuest = json['currentlyViewedQuest'] == null
        ? null
        : Quest.fromJson(json['currentlyViewedQuest'] as Map);

Map<String, dynamic> _$QuestHandlerModelToJson(QuestHandlerModel instance) =>
    <String, dynamic>{
      'activeQuests': instance.activeQuests
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'rejectedQuests': instance.rejectedQuests
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'currentlyViewedQuest': instance.currentlyViewedQuest?.toJson(),
    };
