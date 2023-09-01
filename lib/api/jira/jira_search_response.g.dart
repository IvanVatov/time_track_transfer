// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jira_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JiraSearchResponse _$JiraSearchResponseFromJson(Map<String, dynamic> json) =>
    JiraSearchResponse(
      (json['issues'] as List<dynamic>)
          .map((e) => JiraIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JiraSearchResponseToJson(JiraSearchResponse instance) =>
    <String, dynamic>{
      'issues': instance.issues,
    };
