import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/api/toggl_api.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:intl/intl.dart';
import 'package:time_track_transfer/ui/model/date_issues.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
import 'package:time_track_transfer/util/error_popup.dart';
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

  final List<DateIssues> _dateIssuesList = [];

  late Pair<int, int> _workingHoursPair;
  late Pair<int, int> _startTimePair;

  String? error;

  @override
  void initState() {
    _readConfiguration();
    super.initState();
  }

  Future<void> _readConfiguration() async {
    var configurationJson = await storage.read(Constants.keyConfiguration);
    _configuration = Configuration.fromJson(
        json.decode(configurationJson!) as Map<String, dynamic>);

    _workingHoursPair =
        Pair(_configuration.workingHours!, _configuration.workingHoursMinutes!);
    _startTimePair =
        Pair(_configuration.startingHour!, _configuration.startingHourMinutes!);
  }

  Future<void> _postTimeEntries() async {
    var formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", 'en-US');

    clearError();
    try {
      for (var element in _dateIssuesList) {
        if (!element.isSelected) {
          continue;
        }

        for (var issue in element.issues) {
          if (issue.isSelected) {
            final mapping = issue.mapping;
            if (mapping != null) {
              var workspace = mapping.togglWorkspace!;
              var project = mapping.togglProject!;
              var tag = mapping.togglTag!;

              var data = {
                "billable": true,
                "created_with": "TimeTrackTransfer",
                "description": "${issue.key} ${issue.fields.summary}",
                "duration": issue.duration,
                "project_id": project.id,
                "start": formatter.format(issue.start!.toUtc()),
                "tag_ids": [tag.id],
                "tags": [tag.name],
                "workspace_id": workspace.id
              };

              await Future.delayed(const Duration(milliseconds: 750));

              await _togglApi.postTimeEntries(workspace.id, data);

              issue.isPosted = true;

              setState(() {});
            }
          }
        }
      }
    } catch (e) {
      showErrorMessage('Error while posting data: $e');
      setError(e);
    }
  }

  Future<void> searchIssues() async {
    var firstDay = _dates.first;
    var lastDay = _dates.last;

    _dateIssuesList.clear();

    if (firstDay != null && lastDay != null) {
      clearError();
      try {
        for (var element in getWorkingDaysBetweenDates(firstDay, lastDay)) {
          var dateIssues = DateIssues(element, []);
          var formattedDate = formatter.format(element);

          for (var mapping in _configuration.mappings) {
            var issues = await _jiraApi.search(mapping.jiraProject!.id,
                mapping.jiraStatus!.name, formattedDate);
            for (var issue in issues) {
              issue.mapping = mapping;
            }
            dateIssues.issues.addAll(issues);
          }

          dateIssues.calculatePeriods(_workingHoursPair, _startTimePair);
          _dateIssuesList.add(dateIssues);
          setState(() {});
        }
      } catch (e) {
        setError(e);
      }
    }
  }

  void setError(Object e) {
    setState(() {
      error = e.toString();
      if (e is DioException) {
        error = "$error\n${e.response?.data}";
      }
    });
  }

  void clearError() {
    setState(() {
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var listSize = _dateIssuesList.length;

    if (error != null) {
      listSize++;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _showDatePickerDialog();
            },
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Check for issues',
          ),
          IconButton(
            onPressed: () {
              _postTimeEntries();
            },
            icon: const Icon(Icons.upload_outlined),
            tooltip: 'Push issues to Toggl',
          ),
          IconButton(
            onPressed: () {
              context.pushReplacementNamed(RouteName.config);
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Edit configuration',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView.builder(
          itemBuilder: (context, position) {
            if (position == _dateIssuesList.length) {
              return Heading18(text: error!, color: Colors.red);
            }
            var item = _dateIssuesList[position];
            Color? color;
            if (!item.isSelected) {
              color = Colors.blueGrey;
            }
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
                              for (var element in item.issues) {
                                element.isSelected = item.isSelected;
                              }
                              item.calculatePeriods(
                                  _workingHoursPair, _startTimePair);
                            });
                          }),
                      Heading18(
                          text: DateFormat.yMEd().format(item.dateTime),
                          color: color)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _dateIssuesWidgets(item),
                  )
                ],
              ),
            );
          },
          itemCount: listSize,
        ),
      ),
    );
  }

  List<Widget> _dateIssuesWidgets(DateIssues dateIssues) {
    List<Widget> list = [];

    for (var element in dateIssues.issues) {
      TextStyle style = const TextStyle();
      if (element.isPosted) {
        style = const TextStyle(color: Colors.green);
      } else if (!element.isSelected) {
        style = const TextStyle(color: Colors.blueGrey);
      }

      var startText = "--:--";
      if (element.start != null) {
        startText = DateFormat.Hm().format(element.start!);
      }
      var endText = "--:--";
      if (element.end != null) {
        endText = DateFormat.Hm().format(element.end!);
      }

      list.add(
        ListTile(
          title: Row(children: [
            Checkbox(
                value: element.isSelected,
                onChanged: (value) {
                  element.isSelected = !element.isSelected;
                  if (element.isSelected) {
                    dateIssues.isSelected = true;
                  } else {
                    dateIssues.isSelected = dateIssues.issues.firstWhereOrNull(
                            (element) => element.isSelected) !=
                        null;
                  }
                  dateIssues.calculatePeriods(
                      _startTimePair, _workingHoursPair);
                  setState(() {});
                }),
            TextButton(
              onPressed: () {
                _openUrl(
                    "${_configuration.jiraEndpoint}/browse/${element.key}");
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    textAlign: TextAlign.start,
                    style: style,
                    "${element.key} ${element.fields.summary}"),
              ),
            )
          ]),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(startText), Text(endText)],
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
