// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglProject _$TogglProjectFromJson(Map<String, dynamic> json) => TogglProject(
  (json['id'] as num).toInt(),
  (json['workspace_id'] as num).toInt(),
  json['name'] as String,
  json['active'] as bool,
  json['billable'] as bool? ?? false,
);

Map<String, dynamic> _$TogglProjectToJson(TogglProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'name': instance.name,
      'active': instance.active,
      'billable': instance.billable,
    };
