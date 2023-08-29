import 'package:json_annotation/json_annotation.dart';

part 'jira_project.g.dart';

@JsonSerializable()
class JiraProject {
  String id;
  String name;

  JiraProject(this.id, this.name);

  factory JiraProject.fromJson(Map<String, dynamic> json) =>
      _$JiraProjectFromJson(json);

  Map<String, dynamic> toJson() => _$JiraProjectToJson(
        this,
      );
}
