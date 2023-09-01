// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jira_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JiraTask _$JiraTaskFromJson(Map<String, dynamic> json) => JiraTask(
      json['id'] as String,
      json['name'] as String,
      (json['statuses'] as List<dynamic>)
          .map((e) => JiraStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JiraTaskToJson(JiraTask instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'statuses': instance.statuses,
    };
