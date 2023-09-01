import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/jira_status.dart';

part 'jira_task.g.dart';

@JsonSerializable()
class JiraTask {
  String id;
  String name;
  List<JiraStatus> statuses;

  JiraTask(this.id, this.name, this.statuses);

  factory JiraTask.fromJson(Map<String, dynamic> json) =>
      _$JiraTaskFromJson(json);

  Map<String, dynamic> toJson() => _$JiraTaskToJson(
    this,
  );
}
