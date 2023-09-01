// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglTag _$TogglTagFromJson(Map<String, dynamic> json) => TogglTag(
      json['id'] as int,
      json['workspace_id'] as int,
      json['name'] as String,
    );

Map<String, dynamic> _$TogglTagToJson(TogglTag instance) => <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'name': instance.name,
    };
