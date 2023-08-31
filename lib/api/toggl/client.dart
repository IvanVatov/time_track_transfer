import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  int id;
  int wid;
  bool archived;
  String name;


  Client(this.id, this.wid, this.archived, this.name);

  factory Client.fromJson(Map<String, dynamic> json) =>
      _$ClientFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClientToJson(
        this,
      );
}
