import 'package:time_track_transfer/api/jira/issue.dart';

class DateIssues {
  DateTime dateTime;
  List<Issue> issues;

  late bool isSelected;

  DateIssues(this.dateTime, this.issues) {
    isSelected = issues.isNotEmpty;
  }
}
