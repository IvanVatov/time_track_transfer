import 'package:flutter_test/flutter_test.dart';
import 'package:time_track_transfer/api/jira/jira_fields.dart';
import 'package:time_track_transfer/api/jira/jira_issue.dart';
import 'package:time_track_transfer/ui/model/date_issues.dart';
import 'package:time_track_transfer/util/pair.dart';

void main() {
  test("Test calculatePeriods", () {
    DateIssues dateIssues = DateIssues(DateTime.now(), [
      JiraIssue("1", "self", "ID-1", JiraFields("First issue")),
      JiraIssue("2", "self", "ID-2", JiraFields("Second issue")),
      JiraIssue("3", "self", "ID-3", JiraFields("Third issue"))
      // ,
      // Issue("4", "self", "ID-4", Fields("Fourth issue")),
      // Issue("5", "self", "ID-5", Fields("Fifth issue"))
    ]);

    dateIssues.calculatePeriods(Pair(8, 0), Pair(9, 0));

    expect(dateIssues.issues.last.end.hour, 17);
  });
}
