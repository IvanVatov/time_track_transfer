import 'package:json_annotation/json_annotation.dart';

part 'jira_fields.g.dart';

@JsonSerializable()
class JiraFields {
  String summary;

  JiraFields(this.summary);

  factory JiraFields.fromJson(Map<String, dynamic> json) =>
      _$JiraFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$JiraFieldsToJson(
    this,
  );
}
