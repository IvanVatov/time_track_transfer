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
import 'package:time_track_transfer/ui/screen/config_screen.dart';
import 'package:time_track_transfer/util/response_logs.dart';

@Singleton()
class JiraApi {
  late Configuration configuration;

  JiraApi();

  Options _getHeaderOptions() {
    final String token = utf8.decode(base64.decode(configuration.jiraToken!));
    if (configuration.jiraAuthMethod == JiraAuthorization.bearer.index) {
      return Options(headers: {Constants.keyAuthorization: "${Constants.keyBearer} $token"});
    } else if (configuration.jiraAuthMethod == JiraAuthorization.basic.index) {
        return Options(headers: {Constants.keyAuthorization: "${Constants.keyBasic} ${base64Encode(utf8.encode("${configuration.jiraEmail}:$token"))}"});
    } else if (configuration.jiraAuthMethod == JiraAuthorization.cookie.index) {
      return Options(headers: {Constants.keyCookie: token});
    }
    throw Exception("Not implementer authorization method");
  }

  Future<List<JiraProject>> getProjects() async {
    Response response = await client.get(
        "${configuration.jiraEndpoint}/rest/api/2/project",
        options: _getHeaderOptions());

    if (configuration.enableLogging == true) {
      ResponseLog.writeToFile("JiraGetProjects", response.data.toString());
    }

    return (response.data as List)
        .map((i) => JiraProject.fromJson(i as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<JiraTask>> getStatuses(String projectId) async {
    Response response = await client.get(
        "${configuration.jiraEndpoint}/rest/api/2/project/$projectId/statuses",
        options: _getHeaderOptions());

    if (configuration.enableLogging == true) {
      ResponseLog.writeToFile("JiraGetStatuses", response.data.toString());
    }

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

    if (configuration.enableLogging == true) {
      ResponseLog.writeToFile("JiraSearch", response.data.toString());
    }

    return JiraSearchResponse.fromJson(response.data as Map<String, dynamic>)
        .issues;
  }
}
