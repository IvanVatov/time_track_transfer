import 'package:time_track_transfer/api/jira/jira_issue.dart';
import 'package:time_track_transfer/util/pair.dart';

class DateIssues {
  DateTime dateTime;
  List<JiraIssue> issues;

  late bool isSelected;

  DateIssues(this.dateTime, this.issues) {
    isSelected = issues.isNotEmpty;
  }

  void calculatePeriods(Pair<int, int> workingHours, Pair<int, int> startTime) {
    if (issues.isEmpty) {
      return;
    }

    var workingMinutes = (workingHours.first * 60) + workingHours.second;

    var multiplayer = ((workingMinutes / 15) / issues.length).floor();

    var workPerIssue = multiplayer * 15;

    var nextTime = dateTime.copyWith(
        hour: startTime.first,
        minute: startTime.second,
        second: 0,
        millisecond: 0,
        microsecond: 0);

    for (var element in issues) {
      element.start = nextTime;

      nextTime = nextTime.add(Duration(minutes: workPerIssue));

      element.end = nextTime;
    }

    var shouldAdd = workingMinutes - (workPerIssue * issues.length);
    if (shouldAdd > 0) {
      issues.lastOrNull?.end =
          issues.last.end.add(Duration(minutes: shouldAdd));
    }
  }
}
