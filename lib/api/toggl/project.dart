import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  int id;
  @JsonKey(name: 'workspace_id')
  int workspaceId;
  String name;
  bool active;
  bool billable;


  Project(this.id, this.workspaceId, this.name, this.active, this.billable);

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProjectToJson(
        this,
      );
}
