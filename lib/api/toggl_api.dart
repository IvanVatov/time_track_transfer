import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/toggl/toggl_profile.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/main.dart';

@Singleton()
class TogglApi {
  late Configuration configuration;

  TogglApi();

  Options _getHeaderOptions() {
    return Options(headers: {
      Constants.keyAuthorization:
          "${Constants.keyBasic} ${base64Encode(utf8.encode("${configuration.togglToken}:api_token"))}"
    });
  }

  Future<TogglProfile> getTogglProfile() async {
    Response response = await client.get(
        "https://api.track.toggl.com/api/v9/me?with_related_data=true",
        options: _getHeaderOptions());

    return TogglProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Response> postTimeEntries(int workspaceId, Object data) async {
    Response response = await client.post(
        "https://api.track.toggl.com/api/v9/workspaces/$workspaceId/time_entries",
        options: _getHeaderOptions(),
    data: data);

    return response;
  }
}
