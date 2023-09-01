import 'package:json_annotation/json_annotation.dart';

part 'toggl_tag.g.dart';

@JsonSerializable()
class TogglTag {
  int id;
  @JsonKey(name: 'workspace_id')
  int workspaceId;
  String name;


  TogglTag(this.id, this.workspaceId, this.name);

  factory TogglTag.fromJson(Map<String, dynamic> json) =>
      _$TogglTagFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglTagToJson(
        this,
      );
}
