import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/configuration_mapping.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/jira_status.dart';
import 'package:time_track_transfer/api/jira/jira_task.dart';
import 'package:time_track_transfer/api/toggl/toggl_client.dart';
import 'package:time_track_transfer/api/toggl/toggl_project.dart';
import 'package:time_track_transfer/api/toggl/toggl_tag.dart';
import 'package:time_track_transfer/api/toggl/toggl_workspace.dart';

part 'configuration.g.dart';

@JsonSerializable()
class Configuration {
  String? jiraEndpoint;
  String? jiraEmail;
  String? jiraToken;

  int? jiraAuthMethod;

  String? togglToken;

  List<ConfigurationMapping> mappings;

  int? workingHours;
  int? workingHoursMinutes;

  int? startingHour;
  int? startingHourMinutes;

  bool? enableLogging;

  Configuration(this.mappings);

  factory Configuration.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConfigurationToJson(
        this,
      );
}
