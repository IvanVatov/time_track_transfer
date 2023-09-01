// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) =>
    Configuration()
      ..jiraEndpoint = json['jiraEndpoint'] as String?
      ..jiraEmail = json['jiraEmail'] as String?
      ..jiraToken = json['jiraToken'] as String?
      ..togglToken = json['togglToken'] as String?
      ..jiraProject = json['jiraProject'] == null
          ? null
          : JiraProject.fromJson(json['jiraProject'] as Map<String, dynamic>)
      ..jiraStatus = json['jiraStatus'] == null
          ? null
          : JiraStatus.fromJson(json['jiraStatus'] as Map<String, dynamic>)
      ..jiraTask = json['jiraTask'] == null
          ? null
          : JiraTask.fromJson(json['jiraTask'] as Map<String, dynamic>)
      ..togglWorkspace = json['togglWorkspace'] == null
          ? null
          : TogglWorkspace.fromJson(
              json['togglWorkspace'] as Map<String, dynamic>)
      ..togglClient = json['togglClient'] == null
          ? null
          : TogglClient.fromJson(json['togglClient'] as Map<String, dynamic>)
      ..togglProject = json['togglProject'] == null
          ? null
          : TogglProject.fromJson(json['togglProject'] as Map<String, dynamic>)
      ..togglTag = json['togglTag'] == null
          ? null
          : TogglTag.fromJson(json['togglTag'] as Map<String, dynamic>)
      ..workingHours = json['workingHours'] as int?
      ..workingHoursMinutes = json['workingHoursMinutes'] as int?
      ..startingHour = json['startingHour'] as int?
      ..startingHourMinutes = json['startingHourMinutes'] as int?;

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{
      'jiraEndpoint': instance.jiraEndpoint,
      'jiraEmail': instance.jiraEmail,
      'jiraToken': instance.jiraToken,
      'togglToken': instance.togglToken,
      'jiraProject': instance.jiraProject,
      'jiraStatus': instance.jiraStatus,
      'jiraTask': instance.jiraTask,
      'togglWorkspace': instance.togglWorkspace,
      'togglClient': instance.togglClient,
      'togglProject': instance.togglProject,
      'togglTag': instance.togglTag,
      'workingHours': instance.workingHours,
      'workingHoursMinutes': instance.workingHoursMinutes,
      'startingHour': instance.startingHour,
      'startingHourMinutes': instance.startingHourMinutes,
    };
