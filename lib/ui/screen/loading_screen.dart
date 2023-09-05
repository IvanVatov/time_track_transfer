import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/toggl_api.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/main.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final JiraApi _jiraApi = getIt<JiraApi>();
  final TogglApi _togglApi = getIt<TogglApi>();

  @override
  void initState() {
    checkConfiguration((result) {
      if (result) {
        context.pushReplacementNamed(RouteName.panel);
      } else {
        context.pushReplacementNamed(RouteName.config);
      }
    });
    super.initState();
  }

  Future<void> checkConfiguration(Function(bool) completion) async {
    var configurationString = await storage.read(Constants.keyConfiguration);

    if (configurationString != null) {
      try {
        var configuration = Configuration.fromJson(
            json.decode(configurationString) as Map<String, dynamic>);
        _jiraApi.configuration = configuration;
        _togglApi.configuration = configuration;
        completion(true);
      } catch (e) {
        await storage.delete(Constants.keyConfiguration);
        completion(false);
      }
    } else {
      completion(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SpinKitFoldingCube(
                color: Colors.teal,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
