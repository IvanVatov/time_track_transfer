import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/toggl/client.dart';
import 'package:time_track_transfer/api/toggl/project.dart';
import 'package:time_track_transfer/api/toggl/tag.dart';
import 'package:time_track_transfer/api/toggl/workspace.dart';

part 'toggl_profile.g.dart';

@JsonSerializable()
class TogglProfile {
  String fullname;
  @JsonKey(name: 'default_workspace_id')
  int defaultWorkspaceId;
  List<Tag> tags;
  List<Client> clients;
  List<Project> projects;
  List<Workspace> workspaces;

  TogglProfile(this.fullname, this.defaultWorkspaceId, this.tags, this.clients, this.projects, this.workspaces);

  factory TogglProfile.fromJson(Map<String, dynamic> json) =>
      _$TogglProfileFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglProfileToJson(
        this,
      );
}
