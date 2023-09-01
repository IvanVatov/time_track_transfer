import 'package:json_annotation/json_annotation.dart';

part 'toggl_client.g.dart';

@JsonSerializable()
class TogglClient {
  int id;
  int wid;
  bool archived;
  String name;


  TogglClient(this.id, this.wid, this.archived, this.name);

  factory TogglClient.fromJson(Map<String, dynamic> json) =>
      _$TogglClientFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglClientToJson(
        this,
      );
}
