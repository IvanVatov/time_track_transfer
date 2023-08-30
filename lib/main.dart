import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/ui/screen/config_screen.dart';
import 'package:time_track_transfer/ui/screen/loading_screen.dart';
import 'package:time_track_transfer/ui/screen/panel_screen.dart';
import 'package:time_track_transfer/util/Storage.dart';

const storage = Storage();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {

  HttpOverrides.global = MyHttpOverrides();

  configureDependencies();

  runApp(const TimeTrackTransfer());
}

class RouteName {
  static const config = 'config';
  static const panel = 'panel';
}

final GoRouter routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoadingScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            name: RouteName.config,
            path: RouteName.config,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ConfigScreen(),
            ),
          ),
          GoRoute(
            name: RouteName.panel,
            path: RouteName.panel,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const PanelScreen(),
            ),
          ),
        ]),
  ],
);

class TimeTrackTransfer extends StatelessWidget {
  const TimeTrackTransfer({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routerConfig,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
