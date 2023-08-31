import 'package:flutter_test/flutter_test.dart';
import 'package:time_track_transfer/api/jira/fields.dart';
import 'package:time_track_transfer/api/jira/issue.dart';
import 'package:time_track_transfer/ui/model/date_issues.dart';
import 'package:time_track_transfer/util/pair.dart';

void main() {
  test("Test calculatePeriods", () {
    DateIssues dateIssues = DateIssues(DateTime.now(), [
      Issue("1", "self", "ID-1", Fields("First issue")),
      Issue("2", "self", "ID-2", Fields("Second issue")),
      Issue("3", "self", "ID-3", Fields("Third issue"))
      // ,
      // Issue("4", "self", "ID-4", Fields("Fourth issue")),
      // Issue("5", "self", "ID-5", Fields("Fifth issue"))
    ]);

    dateIssues.calculatePeriods(Pair(8, 0), Pair(9, 0));

    expect(dateIssues.issues.last.end.hour, 17);
  });
}
