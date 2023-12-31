import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/jira_status.dart';
import 'package:time_track_transfer/api/jira/jira_task.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/api/toggl/toggl_client.dart';
import 'package:time_track_transfer/api/toggl/toggl_project.dart';
import 'package:time_track_transfer/api/toggl/toggl_tag.dart';
import 'package:time_track_transfer/api/toggl/toggl_profile.dart';
import 'package:time_track_transfer/api/toggl/toggl_workspace.dart';
import 'package:time_track_transfer/api/toggl_api.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
import 'package:time_track_transfer/constants.dart';
import 'package:collection/collection.dart';
import 'package:time_track_transfer/util/hour_minutes.dart';
import 'package:time_track_transfer/util/pair.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

enum Step { setupJira, selectProject, selectStatus, setupToggl, trackingSetup }

enum JiraAuthorization { basic, bearer }

class _ConfigScreenState extends State<ConfigScreen> {
  final JiraApi _jiraApi = getIt<JiraApi>();

  final TogglApi _togglApi = getIt<TogglApi>();

  Step _step = Step.setupJira;

  Configuration? _configuration;

  List<JiraProject>? _jiraProjects;

  List<JiraTask>? _projectTasks;

  TogglProfile? _togglProfile;

  late TextEditingController _jiraEndpointController;
  late TextEditingController _jiraEmailController;
  late TextEditingController _jiraTokenController;

  late TextEditingController _togglTokenController;

  final FocusNode _workingHoursFocusNode = FocusNode();
  late TextEditingController _workingHours;

  final FocusNode _startTimeFocusNode = FocusNode();
  late TextEditingController _startTime;

  JiraAuthorization _jiraAuthorization = JiraAuthorization.basic;

  String? _error;

  @override
  void initState() {
    _jiraEndpointController = TextEditingController();
    _jiraEmailController = TextEditingController();
    _jiraTokenController = TextEditingController();

    _togglTokenController = TextEditingController();

    _startTime = TextEditingController();
    _startTimeFocusNode.addListener(() {
      if (!_startTimeFocusNode.hasFocus) {
        _startTime.text = parseHourMinutes(_startTime.text).pairToString();
      }
    });

    _workingHours = TextEditingController();
    _workingHoursFocusNode.addListener(() {
      if (!_workingHoursFocusNode.hasFocus) {
        _workingHours.text =
            parseHourMinutes(_workingHours.text).pairToString();
      }
    });

    _readConfiguration();

    super.initState();
  }

  Future<void> getJiraProjects() async {
    clearError();
    try {
      var result = await _jiraApi.getProjects();
      for (var element in result) {
        if (element.id == _configuration?.jiraProject?.id) {
          _configuration?.jiraProject = element;
        }
      }
      setState(() {
        _jiraProjects = result;
        _step = Step.selectProject;
      });
    } catch (e) {
      setError(e);
    }
  }

  Future<void> getStatuses() async {
    clearError();
    try {
      var result = await _jiraApi.getStatuses(_configuration!.jiraProject!.id);
      setState(() {
        _projectTasks = result;
        _step = Step.selectStatus;
      });
    } catch (e) {
      setError(e);
    }
  }

  Future<void> _getTogglProfile() async {
    clearError();
    try {
      var result = await _togglApi.getTogglProfile();

      var nullableBillable = result.projects.where(
          (element) => element.billable == null || element.active == null);

      setState(() {
        _togglProfile = result;
      });
    } catch (e) {
      setError(e);
    }
  }

  void setError(Object e) {
    setState(() {
      _error = e.toString();
      if (e is DioException) {
        _error = "$_error\n${e.response?.data}";
      }
    });
  }

  void clearError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenList;
    if (_error != null) {
      List<Widget> mList = [];
      mList.add(Heading18(text: _error!, color: Colors.red));
      mList.add(const SizedBox(height: 16));
      mList.addAll(_buildWidgets());
      childrenList = mList;
    } else {
      childrenList = _buildWidgets();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await storage.delete(Constants.keyConfiguration);
                _step = Step.setupJira;
                _readConfiguration();
              },
              icon: const Icon(Icons.highlight_remove))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: childrenList,
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
        return _stepTrackingSetup();
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
          const SizedBox(height: 16),
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('Basic'),
                leading: Radio<JiraAuthorization>(
                  value: JiraAuthorization.basic,
                  groupValue: _jiraAuthorization,
                  onChanged: (JiraAuthorization? value) {
                    setState(() {
                      if (value != null) _jiraAuthorization = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Bearer'),
                leading: Radio<JiraAuthorization>(
                  value: JiraAuthorization.bearer,
                  groupValue: _jiraAuthorization,
                  onChanged: (JiraAuthorization? value) {
                    setState(() {
                      if (value != null) _jiraAuthorization = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                Uri jiraUri = Uri.parse(_jiraEndpointController.value.text);

                _configuration?.jiraEndpoint =
                    "${jiraUri.scheme}://${jiraUri.host.toString()}";
                _configuration?.jiraEmail = _jiraEmailController.value.text;
                _configuration?.jiraToken = _jiraTokenController.value.text;
                _configuration?.jiraIsBasic =
                    _jiraAuthorization == JiraAuthorization.basic;

                _jiraApi.configuration = _configuration!;
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
            value: _configuration?.jiraProject,
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
              setState(() {
                if (newValue != _configuration?.jiraProject) {
                  _configuration?.jiraStatus = null;
                  _configuration?.jiraTask = null;
                }
                _configuration?.jiraProject = newValue!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _saveConfiguration();
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

    var current = _projectTasks?.firstWhereOrNull(
        (element) => element.id == _configuration?.jiraTask?.id);
    children.add(
      DropdownButtonFormField<JiraTask>(
        value: current,
        items: _projectTasks!.map<DropdownMenuItem<JiraTask>>((JiraTask value) {
          return DropdownMenuItem<JiraTask>(
            value: value,
            child: Text(value.name),
          );
        }).toList(),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        hint: const Text("Select Task"),
        onChanged: (JiraTask? newValue) {
          setState(() {
            if (newValue != _configuration?.jiraTask) {
              _configuration?.jiraStatus = null;
            }
            _configuration?.jiraTask = newValue!;
          });
        },
      ),
    );

    if (_configuration?.jiraTask != null) {
      var current = _configuration?.jiraTask?.statuses.firstWhereOrNull(
          (element) => element.id == _configuration?.jiraStatus?.id);

      children.add(
        DropdownButtonFormField<JiraStatus>(
          value: current,
          items: _configuration!.jiraTask!.statuses
              .map<DropdownMenuItem<JiraStatus>>((JiraStatus value) {
            return DropdownMenuItem<JiraStatus>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Status"),
          onChanged: (JiraStatus? newValue) {
            setState(() {
              _configuration?.jiraStatus = newValue!;
            });
          },
        ),
      );
      children.add(const SizedBox(height: 16));
      children.add(ElevatedButton(
          onPressed: () {
            _saveConfiguration();
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
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                _configuration?.togglToken = _togglTokenController.value.text;
                _togglApi.configuration = _configuration!;
                _getTogglProfile();
              },
              child: const Text('Next'))
        ],
      ));
    } else {
      var current = _togglProfile?.workspaces.firstWhereOrNull(
          (element) => element.id == _configuration?.togglWorkspace?.id);

      widgets.add(
        DropdownButtonFormField<TogglWorkspace>(
          value: current,
          items: _togglProfile!.workspaces
              .map<DropdownMenuItem<TogglWorkspace>>((TogglWorkspace value) {
            return DropdownMenuItem<TogglWorkspace>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (TogglWorkspace? newValue) {
            setState(() {
              _configuration?.togglWorkspace = newValue!;
              _configuration?.togglClient = null;
              _configuration?.togglProject = null;
              _configuration?.togglTag = null;
            });
          },
        ),
      );

      if (_configuration?.togglWorkspace != null) {
        var current = _togglProfile?.clients.firstWhereOrNull(
            (element) => element.id == _configuration?.togglClient?.id);

        widgets.add(DropdownButtonFormField<TogglClient>(
          value: current,
          items: _togglProfile!.clients
              .where((element) =>
                  element.wid == _configuration?.togglWorkspace?.id)
              .map<DropdownMenuItem<TogglClient>>((TogglClient value) {
            return DropdownMenuItem<TogglClient>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (TogglClient? newValue) {
            setState(() {
              _configuration?.togglClient = newValue;
              _configuration?.togglProject = null;
              _configuration?.togglTag = null;
            });
          },
        ));
      }

      if (_configuration?.togglClient != null) {
        var current = _togglProfile?.projects.firstWhereOrNull(
            (element) => element.id == _configuration?.togglProject?.id);

        widgets.add(DropdownButtonFormField<TogglProject>(
          value: current,
          items: _togglProfile!.projects
              .where((element) =>
                  element.workspaceId == _configuration?.togglWorkspace?.id)
              .map<DropdownMenuItem<TogglProject>>((TogglProject value) {
            return DropdownMenuItem<TogglProject>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (TogglProject? newValue) {
            setState(() {
              _configuration?.togglProject = newValue;
              _configuration?.togglTag = null;
            });
          },
        ));
      }

      if (_configuration?.togglProject != null) {
        var current = _togglProfile?.tags.firstWhereOrNull(
            (element) => element.id == _configuration?.togglTag?.id);

        widgets.add(DropdownButtonFormField<TogglTag>(
          value: current,
          items: _togglProfile!.tags
              .where((element) =>
                  element.workspaceId == _configuration?.togglWorkspace?.id)
              .map<DropdownMenuItem<TogglTag>>((TogglTag value) {
            return DropdownMenuItem<TogglTag>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text("Select Something"),
          onChanged: (TogglTag? newValue) {
            setState(() {
              _configuration?.togglTag = newValue;
            });
          },
        ));
      }

      if (_configuration?.togglTag != null) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(ElevatedButton(
            onPressed: () async {
              setState(() {
                _step = Step.trackingSetup;
              });
            },
            child: const Text('Next')));
      }
    }

    return widgets;
  }

  List<Widget> _stepTrackingSetup() {
    return [
      Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                width: 400,
                child: TextField(
                  controller: _workingHours,
                  focusNode: _workingHoursFocusNode,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Working Hours'),
                )),
            SizedBox(
                width: 400,
                child: TextField(
                  controller: _startTime,
                  focusNode: _startTimeFocusNode,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Start Time'),
                )),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: () async {
              var workingHours = parseHourMinutes(_workingHours.value.text);
              var startTime = parseHourMinutes(_startTime.value.text);

              _configuration?.workingHours = workingHours?.first;
              _configuration?.workingHoursMinutes = workingHours?.second;

              _configuration?.startingHour = startTime?.first;
              _configuration?.startingHourMinutes = startTime?.second;

              _saveConfiguration();

              context.pushReplacementNamed(RouteName.panel);
            },
            child: const Text('Next'))
      ])
    ];
  }

  void _saveConfiguration() {
    storage.write(
        Constants.keyConfiguration, json.encode(_configuration!.toJson()));
  }

  Future<void> _readConfiguration() async {
    var configurationJson = await storage.read(Constants.keyConfiguration);

    if (configurationJson != null) {
      _configuration = Configuration.fromJson(
          json.decode(configurationJson) as Map<String, dynamic>);
    } else {
      _configuration = Configuration();
    }

    var workingHours = _configuration?.workingHours;
    var workingMinutes = _configuration?.workingHoursMinutes;

    if (workingHours != null && workingMinutes != null) {
      var workingHoursStr = Pair(_configuration!.workingHours!,
              _configuration!.workingHoursMinutes!)
          .pairToString();

      _workingHours.value = TextEditingValue(
        text: workingHoursStr,
        selection: TextSelection.fromPosition(
          TextPosition(offset: workingHoursStr.length),
        ),
      );
    } else {
      _workingHours.clear();
    }

    var startingHour = _configuration?.startingHour;
    var startingHourMinutes = _configuration?.startingHourMinutes;

    if (startingHour != null && startingHourMinutes != null) {
      var startingTimeStr =
          Pair(startingHour, startingHourMinutes).pairToString();

      _startTime.value = TextEditingValue(
        text: startingTimeStr,
        selection: TextSelection.fromPosition(
          TextPosition(offset: startingTimeStr.length),
        ),
      );
    } else {
      _startTime.clear();
    }

    if (_configuration?.jiraEndpoint != null) {
      _jiraEndpointController.value = TextEditingValue(
        text: _configuration!.jiraEndpoint!,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _configuration!.jiraEndpoint!.length),
        ),
      );
    } else {
      _jiraEndpointController.clear();
    }

    var jiraEmail = _configuration?.jiraEmail;

    if (jiraEmail != null) {
      _jiraEmailController.value = TextEditingValue(
        text: jiraEmail,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraEmail.length),
        ),
      );
    } else {
      _jiraEmailController.clear();
    }

    var jiraToken = _configuration?.jiraToken;

    if (jiraToken != null) {
      _jiraTokenController.value = TextEditingValue(
        text: jiraToken,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraToken.length),
        ),
      );
    } else {
      _jiraTokenController.clear();
    }

    var jiraIsBasic = _configuration?.jiraIsBasic;
    if (jiraIsBasic != null && jiraIsBasic) {
      _jiraAuthorization = JiraAuthorization.basic;
    } else {
      _jiraAuthorization = JiraAuthorization.bearer;
    }

    var togglToken = _configuration?.togglToken;

    if (togglToken != null) {
      _togglTokenController.value = TextEditingValue(
        text: togglToken,
        selection: TextSelection.fromPosition(
          TextPosition(offset: togglToken.length),
        ),
      );
    } else {
      _togglTokenController.clear();
    }
    setState(() {});
  }
}
