// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jira_issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JiraIssue _$JiraIssueFromJson(Map<String, dynamic> json) => JiraIssue(
      json['id'] as String,
      json['self'] as String,
      json['key'] as String,
      JiraFields.fromJson(json['fields'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JiraIssueToJson(JiraIssue instance) => <String, dynamic>{
      'id': instance.id,
      'self': instance.self,
      'key': instance.key,
      'fields': instance.fields,
    };
