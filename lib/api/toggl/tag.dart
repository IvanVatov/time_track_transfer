import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  int id;
  @JsonKey(name: 'workspace_id')
  int workspaceId;
  String name;


  Tag(this.id, this.workspaceId, this.name);

  factory Tag.fromJson(Map<String, dynamic> json) =>
      _$TagFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TagToJson(
        this,
      );
}
