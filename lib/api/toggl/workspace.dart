import 'package:json_annotation/json_annotation.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace {
  int id;
  String name;
  @JsonKey(name: 'organization_id')
  int organizationId;


  Workspace(this.id, this.name, this.organizationId);

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$WorkspaceToJson(
        this,
      );
}
