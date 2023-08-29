import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/jira/issue.dart';

part 'search_response.g.dart';

@JsonSerializable()
class SearchResponse {
  List<Issue> issues;

  SearchResponse(this.issues);

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(
    this,
  );
}
