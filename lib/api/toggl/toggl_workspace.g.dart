// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglWorkspace _$TogglWorkspaceFromJson(Map<String, dynamic> json) =>
    TogglWorkspace(
      json['id'] as int,
      json['name'] as String,
      json['organization_id'] as int,
    );

Map<String, dynamic> _$TogglWorkspaceToJson(TogglWorkspace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'organization_id': instance.organizationId,
    };
