import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/fields.dart';

part 'issue.g.dart';

@JsonSerializable()
class Issue {
  String id;
  String self;
  String key;
  Fields fields;

  Issue(this.id, this.self, this.key, this.fields);

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

  Map<String, dynamic> toJson() => _$IssueToJson(
        this,
      );
}
