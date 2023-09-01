// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglClient _$TogglClientFromJson(Map<String, dynamic> json) => TogglClient(
      json['id'] as int,
      json['wid'] as int,
      json['archived'] as bool,
      json['name'] as String,
    );

Map<String, dynamic> _$TogglClientToJson(TogglClient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wid': instance.wid,
      'archived': instance.archived,
      'name': instance.name,
    };
