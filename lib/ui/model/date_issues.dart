import 'package:collection/collection.dart';
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

    var length = 0;

    for (var element in issues) {
      if (element.isSelected) {
        length++;
      }
    }

    if (length == 0) {
      for (var element in issues) {
        element.start = null;
        element.end = null;
      }
      return;
    }

    var workingMinutes = (workingHours.first * 60) + workingHours.second;

    var multiplayer = ((workingMinutes / 15) / length).floor();

    var workPerIssue = multiplayer * 15;

    var nextTime = dateTime.copyWith(
        hour: startTime.first,
        minute: startTime.second,
        second: 0,
        millisecond: 0,
        microsecond: 0);

    for (var element in issues) {
      if (element.isSelected) {
        element.start = nextTime;
        element.duration = workPerIssue * 60;
        nextTime = nextTime.add(Duration(minutes: workPerIssue));
        element.end = nextTime;
      } else {
        element.start = null;
        element.end = null;
      }
    }

    var shouldAdd = workingMinutes - (workPerIssue * length);
    if (shouldAdd > 0) {
      var lastIssue = issues.lastWhereOrNull((element) => element.isSelected);
      lastIssue?.duration += shouldAdd * 60;
      lastIssue?.end = lastIssue.end!.add(Duration(minutes: shouldAdd));
    }
  }
}
