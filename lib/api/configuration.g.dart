// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) =>
    Configuration(
      (json['mappings'] as List<dynamic>)
          .map((e) => ConfigurationMapping.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..jiraEndpoint = json['jiraEndpoint'] as String?
      ..jiraEmail = json['jiraEmail'] as String?
      ..jiraToken = json['jiraToken'] as String?
      ..jiraAuthMethod = json['jiraAuthMethod'] as int?
      ..togglToken = json['togglToken'] as String?
      ..workingHours = json['workingHours'] as int?
      ..workingHoursMinutes = json['workingHoursMinutes'] as int?
      ..startingHour = json['startingHour'] as int?
      ..startingHourMinutes = json['startingHourMinutes'] as int?
      ..enableLogging = json['enableLogging'] as bool?;

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{
      'jiraEndpoint': instance.jiraEndpoint,
      'jiraEmail': instance.jiraEmail,
      'jiraToken': instance.jiraToken,
      'jiraAuthMethod': instance.jiraAuthMethod,
      'togglToken': instance.togglToken,
      'mappings': instance.mappings,
      'workingHours': instance.workingHours,
      'workingHoursMinutes': instance.workingHoursMinutes,
      'startingHour': instance.startingHour,
      'startingHourMinutes': instance.startingHourMinutes,
      'enableLogging': instance.enableLogging,
    };
