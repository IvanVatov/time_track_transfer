import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/jira/jira_issue.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/api/toggl_api.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:intl/intl.dart';
import 'package:time_track_transfer/ui/model/date_issues.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
import 'package:time_track_transfer/util/pair.dart';
import 'package:time_track_transfer/util/working_days.dart';
import 'package:url_launcher/url_launcher.dart';

final DateFormat formatter = DateFormat('yyyy/MM/dd');

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  final JiraApi _jiraApi = getIt<JiraApi>();
  final TogglApi _togglApi = getIt<TogglApi>();

  late Configuration _configuration;

  List<DateTime?> _dates = [];

  final List<DateIssues> _dateIssues = [];

  @override
  void initState() {
    _readConfiguration();
    super.initState();
  }

  Future<void> _readConfiguration() async {
    var configurationJson = await storage.read(Constants.keyConfiguration);
    _configuration = Configuration.fromJson(
        json.decode(configurationJson!) as Map<String, dynamic>);
  }

  Future<void> _postTimeEntries() async {
    var workspace = _configuration.togglWorkspace!;
    var project = _configuration.togglProject!;
    var tag = _configuration.togglTag!;

    var formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", 'en-US');

    for (var element in _dateIssues) {
      if (!element.isSelected) {
        continue;
      }

      for (var issue in element.issues) {
        var data = {
          "billable": true,
          "created_with": "TimeTrackTransfer",
          "description": "${issue.key} ${issue.fields.summary}",
          "duration": issue.duration,
          "project_id": project.id,
          "start": formatter.format(issue.start.toUtc()),
          "tag_ids": [tag.id],
          "tags": [tag.name],
          "workspace_id": workspace.id
        };

        await _togglApi.postTimeEntries(workspace.id, data);

        issue.isPosted = true;

        setState(() {});
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> searchIssues() async {
    var firstDay = _dates.first;
    var lastDay = _dates.last;

    _dateIssues.clear();

    if (firstDay != null && lastDay != null) {
      for (var element in getWorkingDaysBetweenDates(firstDay, lastDay)) {
        var formattedDate = formatter.format(element);
        var issues = await _jiraApi.search(_configuration.jiraProject!.id,
            _configuration.jiraStatus!.name, formattedDate);
        var dateIssues = DateIssues(element, issues);
        dateIssues.calculatePeriods(
            Pair(_configuration.workingHours!,
                _configuration.workingHoursMinutes!),
            Pair(_configuration.startingHour!,
                _configuration.startingHourMinutes!));
        _dateIssues.add(dateIssues);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _showDatePickerDialog();
              },
              icon: const Icon(Icons.calendar_month)),
          IconButton(
              onPressed: () {
                _postTimeEntries();
              },
              icon: const Icon(Icons.upload)),
          IconButton(
              onPressed: () {
                context.pushReplacementNamed(RouteName.config);
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView.builder(
          itemBuilder: (context, position) {
            var item = _dateIssues[position];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                          value: item.isSelected,
                          onChanged: (value) {
                            if (item.issues.isEmpty) {
                              return;
                            }
                            setState(() {
                              item.isSelected = !item.isSelected;
                            });
                          }),
                      Heading18(text: DateFormat.yMEd().format(item.dateTime))
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _dateIssuesWidgets(item.issues),
                  )
                ],
              ),
            );
          },
          itemCount: _dateIssues.length,
        ),
      ),
    );
  }

  List<Widget> _dateIssuesWidgets(List<JiraIssue> issues) {
    List<Widget> list = [];

    for (var element in issues) {
      TextStyle style = const TextStyle();
      if (element.isPosted) {
        style = const TextStyle(color: Colors.green);
      }
      list.add(
        ListTile(
          title: TextButton(
            onPressed: () {
              _openUrl("${_configuration.jiraEndpoint}/browse/${element.key}");
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  textAlign: TextAlign.start,
                  style : style,
                  "${element.key} ${element.fields.summary}"),
            ),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.Hm().format(element.start)),
                Text(DateFormat.Hm().format(element.end))
              ],
            ),
          ),
        ),
      );
    }

    return list;
  }

  Future<void> _openUrl(String link) async {
    Uri url = Uri.parse(link);
    await launchUrl(url);
  }

  Future<void> _showDatePickerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select period'),
          content: SizedBox(
            width: 400,
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
              ),
              value: _dates,
              onValueChanged: (dates) => _dates = dates,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                searchIssues();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
