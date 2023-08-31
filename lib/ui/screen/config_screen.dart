import 'package:flutter/material.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/status.dart';
import 'package:time_track_transfer/api/jira/task.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/api/toggl/client.dart';
import 'package:time_track_transfer/api/toggl/project.dart';
import 'package:time_track_transfer/api/toggl/tag.dart';
import 'package:time_track_transfer/api/toggl/toggl_profile.dart';
import 'package:time_track_transfer/api/toggl/workspace.dart';
import 'package:time_track_transfer/api/toggl_api.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:collection/collection.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

enum Step { setupJira, selectProject, selectStatus, setupToggl, trackingSetup }

class _ConfigScreenState extends State<ConfigScreen> {
  final JiraApi _jiraApi = getIt<JiraApi>();

  final TogglApi _togglApi = getIt<TogglApi>();

  Step _step = Step.setupJira;

  List<JiraProject>? _jiraProjects;

  JiraProject? _projectSelection;
  String? _jiraProjectId;

  List<Task>? _projectTasks;

  Task? _taskSelection;
  String? _jiraTaskName;

  Status? _statusSelection;
  String? _jiraStatusId;

  TogglProfile? _togglProfile;

  Workspace? _togglWorkspace;
  int? _togglWorkspaceId;

  Client? _togglClient;
  int? _togglClientId;

  Project? _togglProject;
  int? _togglProjectId;

  Tag? _togglTag;
  int? _togglTagId;

  late TextEditingController _jiraEndpointController;
  late TextEditingController _jiraEmailController;
  late TextEditingController _jiraTokenController;

  late TextEditingController _togglTokenController;

  @override
  void initState() {
    _jiraEndpointController = TextEditingController();
    _jiraEmailController = TextEditingController();
    _jiraTokenController = TextEditingController();

    _togglTokenController = TextEditingController();

    _readStoredState();

    super.initState();
  }

  Future<void> getJiraProjects() async {
    try {
      var result = await _jiraApi.getProjects();
      for (var element in result) {
        if (element.id == _jiraProjectId) {
          _projectSelection = element;
        }
      }
      setState(() {
        _jiraProjects = result;
        _step = Step.selectProject;
      });

      storage.write(
          Constants.keyJiraEndpoint, _jiraEndpointController.value.text);
      storage.write(Constants.keyJiraEmail, _jiraEmailController.value.text);
      storage.write(Constants.keyJiraToken, _jiraTokenController.value.text);
    } catch (t) {
      t;
    }
  }

  Future<void> getStatuses() async {
    try {
      var result = await _jiraApi.getStatuses(_jiraProjectId!);

      setState(() {
        _projectTasks = result;
        _step = Step.selectStatus;
      });
    } catch (t) {
      t;
    }
  }

  Future<void> _getTogglProfile() async {
    try {
      var result = await _togglApi.getTogglProfile();

      setState(() {
        _togglProfile = result;
      });
    } catch (t) {
      print(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: _buildWidgets(),
        ),
      ),
    );
  }

  List<Widget> _buildWidgets() {
    switch (_step) {
      case Step.setupJira:
        return _stepJiraConfig();
      case Step.selectProject:
        return _stepSelectProject();
      case Step.selectStatus:
        return _stepSelectStatus();
      case Step.setupToggl:
        return _stepToggleSetup();
      case Step.trackingSetup:
        return _stepToggleSetup();
    }
  }

  List<Widget> _stepJiraConfig() {
    return [
      Column(
        children: [
          const Heading18(text: "Jira Configuration"),
          const SizedBox(height: 8),
          TextField(
            controller: _jiraEndpointController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Jira endpoint'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jiraEmailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Jira email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jiraTokenController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Jira API token'),
          ),
          ElevatedButton(
              onPressed: () {
                _jiraApi.jiraEndpoint = _jiraEndpointController.value.text;
                _jiraApi.jiraEmail = _jiraEmailController.value.text;
                _jiraApi.jiraToken = _jiraTokenController.value.text;
                getJiraProjects();
              },
              child: const Text('Next'))
        ],
      )
    ];
  }

  List<Widget> _stepSelectProject() {
    return [
      Column(
        children: [
          DropdownButtonFormField<JiraProject>(
            value: _projectSelection,
            items: _jiraProjects!
                .map<DropdownMenuItem<JiraProject>>((JiraProject value) {
              return DropdownMenuItem<JiraProject>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text("Select Something"),
            onChanged: (JiraProject? newValue) {
              setState(() async {
                if (newValue != _projectSelection) {
                  _jiraStatusId = null;
                  _jiraTaskName = null;
                  storage.delete(Constants.keyJiraStatusId);
                  storage.delete(Constants.keyJiraTaskName);
                }
                _projectSelection = newValue!;
              });
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _jiraProjectId = _projectSelection?.id;
                  storage.write(
                      Constants.keyJiraProjectId, _projectSelection!.id);
                  getStatuses();
                });
              },
              child: const Text('Next'))
        ],
      )
    ];
  }

  List<Widget> _stepSelectStatus() {
    List<Widget> children = [];

    if (_jiraTaskName != null && _taskSelection == null) {
      _taskSelection = _projectTasks
          ?.firstWhereOrNull((element) => element.id == _jiraTaskName);
    }

    children.add(
      DropdownButtonFormField<Task>(
        value: _taskSelection,
        items: _projectTasks!.map<DropdownMenuItem<Task>>((Task value) {
          return DropdownMenuItem<Task>(
            value: value,
            child: Text(value.name),
          );
        }).toList(),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        hint: const Text("Select Task"),
        onChanged: (Task? newValue) {
          setState(() {
            if (newValue != _taskSelection) {
              _jiraStatusId = null;
              storage.delete(Constants.keyJiraStatusId);
            }
            _taskSelection = newValue!;
          });
        },
      ),
    );

    if (_taskSelection != null) {
      if (_jiraStatusId != null && _statusSelection == null) {
        _statusSelection = _taskSelection?.statuses
            .firstWhereOrNull((element) => element.name == _jiraStatusId);
      }

      children.add(
        DropdownButtonFormField<Status>(
          value: _statusSelection,
          items: _taskSelection!.statuses
              .map<DropdownMenuItem<Status>>((Status value) {
            return DropdownMenuItem<Status>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Status"),
          onChanged: (Status? newValue) {
            setState(() {
              _statusSelection = newValue!;
            });
          },
        ),
      );
      children.add(ElevatedButton(
          onPressed: () {
            storage.write(Constants.keyJiraTaskName, _taskSelection!.id);
            storage.write(Constants.keyJiraStatusId, _statusSelection!.name);
            setState(() {
              _step = Step.setupToggl;
            });
          },
          child: const Text('Next')));
    }

    return [
      Column(
        children: children,
      )
    ];
  }

  List<Widget> _stepToggleSetup() {
    List<Widget> widgets = [];
    if (_togglProfile == null) {
      widgets.add(Column(
        children: [
          const Heading18(text: "Toggl Configuration"),
          const SizedBox(height: 8),
          TextField(
            controller: _togglTokenController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Toggl token'),
          ),
          ElevatedButton(
              onPressed: () {
                _togglApi.togglToken = _togglTokenController.value.text;
                _getTogglProfile();
              },
              child: const Text('Next'))
        ],
      ));
    } else {

      if(_togglWorkspaceId != null && _togglWorkspace == null) {
        _togglWorkspace = _togglProfile?.workspaces.firstWhereOrNull((element) => element.id == _togglWorkspaceId);
      }

      widgets.add(
        DropdownButtonFormField<Workspace>(
          value: _togglWorkspace,
          items: _togglProfile!.workspaces
              .map<DropdownMenuItem<Workspace>>((Workspace value) {
            return DropdownMenuItem<Workspace>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (Workspace? newValue) {
            setState(() {
              _togglWorkspace = newValue!;
              _togglClient = null;
              _togglProject = null;
              _togglTag = null;
            });
          },
        ),
      );

      if (_togglWorkspace != null) {

        if(_togglClientId != null && _togglClient == null) {
          _togglClient = _togglProfile?.clients.firstWhereOrNull((element) => element.id == _togglClientId);
        }

        widgets.add(DropdownButtonFormField<Client>(
          value: _togglClient,
          items: _togglProfile!.clients
              .where((element) => element.wid == _togglWorkspace?.id)
              .map<DropdownMenuItem<Client>>((Client value) {
            return DropdownMenuItem<Client>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (Client? newValue) {
            setState(() {
              _togglClient = newValue;
              _togglProject = null;
              _togglTag = null;
            });
          },
        ));
      }

      if (_togglClient != null) {

        if(_togglProjectId != null && _togglProject == null) {
          _togglProject = _togglProfile?.projects.firstWhereOrNull((element) => element.id == _togglProjectId);
        }

        widgets.add(DropdownButtonFormField<Project>(
          value: _togglProject,
          items: _togglProfile!.projects
              .map<DropdownMenuItem<Project>>((Project value) {
            return DropdownMenuItem<Project>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (Project? newValue) {
            setState(() {
              _togglProject = newValue;
              _togglTag = null;
            });
          },
        ));
      }

      if (_togglProject != null) {

        if(_togglTagId != null && _togglTag == null) {
          _togglTag = _togglProfile?.tags.firstWhereOrNull((element) => element.id == _togglTagId);
        }

        widgets.add(DropdownButtonFormField<Tag>(
          value: _togglTag,
          items: _togglProfile!.tags
              .where((element) => element.workspaceId == _togglWorkspace?.id)
              .map<DropdownMenuItem<Tag>>((Tag value) {
            return DropdownMenuItem<Tag>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (Tag? newValue) {
            setState(() {
              _togglTag = newValue;
            });
          },
        ));
      }

      if (_togglTag != null) {
        widgets.add(ElevatedButton(
            onPressed: () async {
              storage.write(
                  Constants.keyTogglToken, _togglTokenController.value.text);
              storage.write(Constants.keyTogglWorkspaceId,
                  _togglWorkspace!.id.toString());
              storage.write(
                  Constants.keyTogglClientId, _togglClient!.id.toString());
              storage.write(
                  Constants.keyTogglProjectId, _togglProject!.id.toString());
              storage.write(Constants.keyTogglTagId, _togglTag!.id.toString());

              setState(() {
                _step = Step.trackingSetup;
              });
            },
            child: const Text('Next')));
      } // Tag? _togglTag;
    }

    return widgets;
  }

  Future<void> _readStoredState() async {
    var jiraEndpoint = await storage.read(Constants.keyJiraEndpoint);
    var jiraEmail = await storage.read(Constants.keyJiraEmail);
    var jiraToken = await storage.read(Constants.keyJiraToken);
    _jiraProjectId = await storage.read(Constants.keyJiraProjectId);
    _jiraStatusId = await storage.read(Constants.keyJiraStatusId);
    _jiraTaskName = await storage.read(Constants.keyJiraTaskName);

    var togglToken = await storage.read(Constants.keyTogglToken);
    _togglWorkspaceId =
        await storage.readIntOrNull(Constants.keyTogglWorkspaceId);
    _togglClientId = await storage.readIntOrNull(Constants.keyTogglClientId);
    _togglProjectId = await storage.readIntOrNull(Constants.keyTogglProjectId);
    _togglTagId = await storage.readIntOrNull(Constants.keyTogglTagId);

    if (jiraEndpoint != null) {
      _jiraEndpointController.value = TextEditingValue(
        text: jiraEndpoint,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraEndpoint.length),
        ),
      );
    }

    if (jiraEmail != null) {
      _jiraEmailController.value = TextEditingValue(
        text: jiraEmail,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraEmail.length),
        ),
      );
    }

    if (jiraToken != null) {
      _jiraTokenController.value = TextEditingValue(
        text: jiraToken,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraToken.length),
        ),
      );
    }

    if (togglToken != null) {
      _togglTokenController.value = TextEditingValue(
        text: togglToken,
        selection: TextSelection.fromPosition(
          TextPosition(offset: togglToken.length),
        ),
      );
    }
  }
}
