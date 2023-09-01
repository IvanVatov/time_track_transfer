import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/jira_issue.dart';

part 'jira_search_response.g.dart';

@JsonSerializable()
class JiraSearchResponse {
  List<JiraIssue> issues;

  JiraSearchResponse(this.issues);

  factory JiraSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$JiraSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JiraSearchResponseToJson(
    this,
  );
}
