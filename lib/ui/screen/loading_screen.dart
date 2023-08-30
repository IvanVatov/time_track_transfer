import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final JiraApi jiraApi = getIt<JiraApi>();

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
    var jiraEndpoint = await storage.read(Constants.keyJiraEndpoint);
    var jiraEmail = await storage.read(Constants.keyJiraEmail);
    var jiraToken = await storage.read(Constants.keyJiraToken);

    if (jiraEndpoint != null &&
        jiraEndpoint.isNotEmpty &&
        jiraToken != null &&
        jiraToken.isNotEmpty &&
        jiraEmail != null &&
        jiraEmail.isNotEmpty) {

      jiraApi.jiraEndpoint = jiraEndpoint;
      jiraApi.jiraEmail = jiraEmail;
      jiraApi.jiraToken = jiraToken;

      completion(true);
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
