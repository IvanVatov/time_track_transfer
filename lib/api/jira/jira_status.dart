import 'package:json_annotation/json_annotation.dart';

part 'jira_status.g.dart';

@JsonSerializable()
class JiraStatus {
  String id;
  String name;

  JiraStatus(this.id, this.name);

  factory JiraStatus.fromJson(Map<String, dynamic> json) =>
      _$JiraStatusFromJson(json);

  Map<String, dynamic> toJson() => _$JiraStatusToJson(
    this,
  );
}
