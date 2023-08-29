import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/status.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  String id;
  String name;
  List<Status> statuses;

  Task(this.id, this.name, this.statuses);

  factory Task.fromJson(Map<String, dynamic> json) =>
      _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(
    this,
  );
}
