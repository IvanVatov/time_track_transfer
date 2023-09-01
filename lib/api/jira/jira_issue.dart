import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/jira_fields.dart';

part 'jira_issue.g.dart';

@JsonSerializable()
class JiraIssue {
  String id;
  String self;
  String key;
  JiraFields fields;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late DateTime start;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late DateTime end;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late int duration;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isPosted = false;

  JiraIssue(this.id, this.self, this.key, this.fields);

  factory JiraIssue.fromJson(Map<String, dynamic> json) => _$JiraIssueFromJson(json);

  Map<String, dynamic> toJson() => _$JiraIssueToJson(
        this,
      );
}
