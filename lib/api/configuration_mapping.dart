import 'package:json_annotation/json_annotation.dart';

import 'jira/jira_project.dart';
import 'jira/jira_status.dart';
import 'jira/jira_task.dart';
import 'toggl/toggl_client.dart';
import 'toggl/toggl_project.dart';
import 'toggl/toggl_tag.dart';
import 'toggl/toggl_workspace.dart';

part 'configuration_mapping.g.dart';

@JsonSerializable()
class ConfigurationMapping {
  JiraProject? jiraProject;
  JiraStatus? jiraStatus;
  JiraTask? jiraTask;

  TogglWorkspace? togglWorkspace;
  TogglClient? togglClient;
  TogglProject? togglProject;
  TogglTag? togglTag;

  ConfigurationMapping();

  factory ConfigurationMapping.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationMappingFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConfigurationMappingToJson(
        this,
      );

}
