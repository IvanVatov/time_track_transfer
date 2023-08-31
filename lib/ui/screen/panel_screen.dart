import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/jira/issue.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:intl/intl.dart';
import 'package:time_track_transfer/ui/model/date_issues.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
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

  List<DateTime?> _dates = [];

  late String _jiraProjectId;
  late String _jiraStatusId;

  final List<DateIssues> _dateIssues = [];

  @override
  void initState() {
    _readStoredState();
    super.initState();
  }

  Future<void> _readStoredState() async {
    var projectId = await storage.read(Constants.keyJiraProjectId);
    var status = await storage.read(Constants.keyJiraStatusId);

    if (projectId != null) {
      _jiraProjectId = projectId;
    }
    if (status != null) {
      _jiraStatusId = status;
    }
  }

  Future<void> searchIssues() async {
    var firstDay = _dates.first;
    var lastDay = _dates.last;

    _dateIssues.clear();

    if (firstDay != null && lastDay != null) {
      for (var element in getWorkingDaysBetweenDates(firstDay, lastDay)) {
        var formattedDate = formatter.format(element);
        var issues = await _jiraApi.search(_jiraProjectId, _jiraStatusId, formattedDate);
        _dateIssues.add(DateIssues(element, issues));
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
                            if (item.issues.isEmpty){
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

  List<Widget> _dateIssuesWidgets(List<Issue> issues) {
    List<Widget> list = [];

    for (var element in issues) {
      list.add(TextButton(
          onPressed: () {
            _openUrl("${_jiraApi.jiraEndpoint}/browse/${element.key}");
          },
          child: Text("${element.key} ${element.fields.summary}")));
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
