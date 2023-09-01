import 'package:json_annotation/json_annotation.dart';

part 'toggl_workspace.g.dart';

@JsonSerializable()
class TogglWorkspace {
  int id;
  String name;
  @JsonKey(name: 'organization_id')
  int organizationId;


  TogglWorkspace(this.id, this.name, this.organizationId);

  factory TogglWorkspace.fromJson(Map<String, dynamic> json) =>
      _$TogglWorkspaceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglWorkspaceToJson(
        this,
      );
}
