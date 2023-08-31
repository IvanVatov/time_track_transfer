// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglProfile _$TogglProfileFromJson(Map<String, dynamic> json) => TogglProfile(
      json['fullname'] as String,
      json['default_workspace_id'] as int,
      (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['clients'] as List<dynamic>)
          .map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['workspaces'] as List<dynamic>)
          .map((e) => Workspace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TogglProfileToJson(TogglProfile instance) =>
    <String, dynamic>{
      'fullname': instance.fullname,
      'default_workspace_id': instance.defaultWorkspaceId,
      'tags': instance.tags,
      'clients': instance.clients,
      'projects': instance.projects,
      'workspaces': instance.workspaces,
    };
