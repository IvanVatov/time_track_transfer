import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/jira/jira_issue.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/jira_search_response.dart';
import 'package:time_track_transfer/api/jira/jira_task.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/main.dart';

@Singleton()
class JiraApi {
  late Configuration configuration;

  JiraApi();

  Options _getHeaderOptions() {
    String authorization;
    if (configuration.jiraIsBasic == true) {
      authorization = "${Constants.keyBearer} ${configuration.jiraToken}";
    } else {
      authorization =
          "${Constants.keyBasic} ${base64Encode(utf8.encode("${configuration.jiraEmail}:${configuration.jiraToken}"))}";
    }
    return Options(headers: {Constants.keyAuthorization: authorization});
  }

  Future<List<JiraProject>> getProjects() async {
    Response response = await client.get(
        "${configuration.jiraEndpoint}/rest/api/2/project",
        options: _getHeaderOptions());

    return (response.data as List)
        .map((i) => JiraProject.fromJson(i as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<JiraTask>> getStatuses(String projectId) async {
    Response response = await client.get(
        "${configuration.jiraEndpoint}/rest/api/2/project/$projectId/statuses",
        options: _getHeaderOptions());

    return (response.data as List)
        .map((i) => JiraTask.fromJson(i as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<JiraIssue>> search(
      String projectId, String status, String date) async {
    Response response = await client.post(
        "${configuration.jiraEndpoint}/rest/api/2/search",
        options: _getHeaderOptions(),
        data:
            "{\"jql\":\"project = $projectId AND assignee was currentUser() on '$date' AND status was '$status' on '$date'\", \"fields\":[\"key\", \"summary\"]}");

    return JiraSearchResponse.fromJson(response.data as Map<String, dynamic>)
        .issues;
  }
}
