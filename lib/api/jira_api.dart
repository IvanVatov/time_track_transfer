import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';
import 'package:time_track_transfer/api/jira/issue.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/search_response.dart';
import 'package:time_track_transfer/api/jira/task.dart';
import 'package:time_track_transfer/constants.dart';

@Singleton(dispose: disposeApiService)
class JiraApi {
  final Dio _client = Dio()
  ..httpClientAdapter =
      IOHttpClientAdapter(onHttpClientCreate: (client) {
    client.findProxy = (uri) {
      return 'PROXY localhost:8888';
    };
    return client;
  });

  late String jiraEndpoint;
  late String jiraEmail;
  late String jiraToken;

  JiraApi();

  Options _getHeaderOptions() {
    return Options(headers: {
      Constants.keyAuthorization:
          "${Constants.keyBasic} ${base64Encode(utf8.encode("$jiraEmail:$jiraToken"))}"
    });
  }

  Future<List<JiraProject>> getProjects() async {
    Response response = await _client.get("$jiraEndpoint/rest/api/2/project",
        options: _getHeaderOptions());

    return (response.data as List)
        .map((i) => JiraProject.fromJson(i as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Task>> getStatuses(String projectId) async {
    Response response = await _client.get(
        "$jiraEndpoint/rest/api/2/project/$projectId/statuses",
        options: _getHeaderOptions());

    return (response.data as List)
        .map((i) => Task.fromJson(i as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Issue>> search(String projectId, String status, String date) async {
    Response response = await _client.post("$jiraEndpoint/rest/api/2/search",
        options: _getHeaderOptions(),
        data:
            "{\"jql\":\"project = $projectId AND assignee was currentUser() on '$date' AND status was '$status' on '$date'\", \"fields\":[\"key\", \"summary\"]}");

    return SearchResponse.fromJson(response.data as Map<String, dynamic>).issues;
  }

  void dispose() {
    _client.close();
  }
}

FutureOr disposeApiService(JiraApi instance) {
  instance.dispose();
}
