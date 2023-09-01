import 'package:json_annotation/json_annotation.dart';
import 'package:time_track_transfer/api/toggl/toggl_client.dart';
import 'package:time_track_transfer/api/toggl/toggl_project.dart';
import 'package:time_track_transfer/api/toggl/toggl_tag.dart';
import 'package:time_track_transfer/api/toggl/toggl_workspace.dart';

part 'toggl_profile.g.dart';

@JsonSerializable()
class TogglProfile {
  String fullname;
  @JsonKey(name: 'default_workspace_id')
  int defaultWorkspaceId;
  List<TogglTag> tags;
  List<TogglClient> clients;
  List<TogglProject> projects;
  List<TogglWorkspace> workspaces;

  TogglProfile(this.fullname, this.defaultWorkspaceId, this.tags, this.clients, this.projects, this.workspaces);

  factory TogglProfile.fromJson(Map<String, dynamic> json) =>
      _$TogglProfileFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TogglProfileToJson(
        this,
      );
}
