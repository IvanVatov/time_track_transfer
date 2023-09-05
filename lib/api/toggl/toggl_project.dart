import 'package:json_annotation/json_annotation.dart';

part 'toggl_project.g.dart';

@JsonSerializable()
class TogglProject {
  int id;
  @JsonKey(name: 'workspace_id')
  int workspaceId;
  String name;
  bool active;
  @JsonKey(defaultValue: false)
  bool billable;


  TogglProject(this.id, this.workspaceId, this.name, this.active, this.billable);

  factory TogglProject.fromJson(Map<String, dynamic> json) =>
      _$TogglProjectFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglProjectToJson(
        this,
      );
}
