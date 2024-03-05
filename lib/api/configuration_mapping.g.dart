// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigurationMapping _$ConfigurationMappingFromJson(
        Map<String, dynamic> json) =>
    ConfigurationMapping()
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
          : TogglTag.fromJson(json['togglTag'] as Map<String, dynamic>);

Map<String, dynamic> _$ConfigurationMappingToJson(
        ConfigurationMapping instance) =>
    <String, dynamic>{
      'jiraProject': instance.jiraProject,
      'jiraStatus': instance.jiraStatus,
      'jiraTask': instance.jiraTask,
      'togglWorkspace': instance.togglWorkspace,
      'togglClient': instance.togglClient,
      'togglProject': instance.togglProject,
      'togglTag': instance.togglTag,
    };
