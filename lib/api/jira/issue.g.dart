// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Issue _$IssueFromJson(Map<String, dynamic> json) => Issue(
      json['id'] as String,
      json['self'] as String,
      json['key'] as String,
      Fields.fromJson(json['fields'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IssueToJson(Issue instance) => <String, dynamic>{
      'id': instance.id,
      'self': instance.self,
      'key': instance.key,
      'fields': instance.fields,
    };
