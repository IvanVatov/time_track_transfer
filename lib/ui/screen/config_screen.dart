import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/configuration.dart';
import 'package:time_track_transfer/api/configuration_mapping.dart';
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
import 'package:time_track_transfer/util/error_popup.dart';
import 'package:time_track_transfer/util/hour_minutes.dart';
import 'package:time_track_transfer/util/pair.dart';
import 'package:time_track_transfer/util/success_popup.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

enum Step { setupJira, selectProject, selectStatus, setupToggl, trackingSetup }

enum JiraAuthorization { basic, bearer, cookie }

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

  bool _enableLogging = false;

  ConfigurationMapping _currentMapping = ConfigurationMapping();

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

    if (_configuration?.enableLogging != null) {
      _enableLogging = _configuration!.enableLogging!;
    }

    super.initState();
  }

  Future<void> getJiraProjects() async {
    clearError();
    try {
      var result = await _jiraApi.getProjects();
      for (var element in result) {
        if (element.id == _currentMapping.jiraProject?.id) {
          _currentMapping.jiraProject = element;
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
      var result = await _jiraApi.getStatuses(_currentMapping.jiraProject!.id);
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

  void _toggleSwitch(bool value) {
    setState(() {
      _enableLogging = !_enableLogging;
      _configuration?.enableLogging = _enableLogging;
    });
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
              final outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Please select an output file:',
                fileName: 'time_track_transfer.txt',
              );
              final config = _configuration;
              if (outputFile != null && config != null) {
                try {
                  final file = File(outputFile);
                  file.create();
                  file.writeAsString(prettyJson.convert(config.toJson()));
                  showSuccessMessage('Configuration saved successfully!');
                } catch (e) {
                  showErrorMessage('Unable to save configuration file!');
                }
              } else {
                showErrorMessage('Canceled');
              }
            },
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Export configuration',
          ),
          IconButton(
            onPressed: () async {
              final inputFile = await FilePicker.platform.pickFiles();

              if (inputFile != null) {
                try {
                  File file = File(inputFile.files.single.path!);
                  final config = Configuration.fromJson(
                      jsonDecode(file.readAsStringSync())
                          as Map<String, dynamic>);

                  setState(() {
                    _configuration = config;
                    _saveConfiguration();
                    showSuccessMessage('Configuration loaded successfully!');
                  });
                } catch (e) {
                  showErrorMessage('Invalid configuration file!');
                }
              } else {
                showErrorMessage('Canceled');
              }
            },
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Import configuration',
          ),
          IconButton(
            onPressed: () async {
              await storage.delete(Constants.keyConfiguration);
              _step = Step.setupJira;
              _readConfiguration();
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear configuration',
          ),
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
          ListTile(
              title: const Heading18(text: 'Response Logging'),
              subtitle: const Text(
                'write responses to user documents folder',
              ),
              trailing: Switch(
                value: _enableLogging,
                onChanged: _toggleSwitch,
                activeColor: Colors.deepPurple,
              )),
          const SizedBox(height: 16),
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
                border: OutlineInputBorder(), labelText: 'Jira API token or cookie'),
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
              ListTile(
                title: const Text('Cookie'),
                leading: Radio<JiraAuthorization>(
                  value: JiraAuthorization.cookie,
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
                _configuration?.jiraToken = base64UrlEncode(
                    utf8.encode(_jiraTokenController.value.text));
                _configuration?.jiraAuthMethod = _jiraAuthorization.index;

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
            value: _currentMapping.jiraProject,
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
                if (newValue != _currentMapping.jiraProject) {
                  _currentMapping.jiraStatus = null;
                  _currentMapping.jiraTask = null;
                }
                _currentMapping.jiraProject = newValue!;
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
        (element) => element.id == _currentMapping.jiraTask?.id);
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
            if (newValue != _currentMapping.jiraTask) {
              _currentMapping.jiraStatus = null;
            }
            _currentMapping.jiraTask = newValue!;
          });
        },
      ),
    );

    if (_currentMapping.jiraTask != null) {
      var current = _currentMapping.jiraTask?.statuses.firstWhereOrNull(
          (element) => element.id == _currentMapping.jiraStatus?.id);

      children.add(
        DropdownButtonFormField<JiraStatus>(
          value: current,
          items: _currentMapping.jiraTask!.statuses
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
              _currentMapping.jiraStatus = newValue!;
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
          (element) => element.id == _currentMapping.togglWorkspace?.id);

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
              _currentMapping.togglWorkspace = newValue!;
              _currentMapping.togglClient = null;
              _currentMapping.togglProject = null;
              _currentMapping.togglTag = null;
            });
          },
        ),
      );

      if (_currentMapping.togglWorkspace != null) {
        var current = _togglProfile?.clients.firstWhereOrNull(
            (element) => element.id == _currentMapping.togglClient?.id);

        widgets.add(DropdownButtonFormField<TogglClient>(
          value: current,
          items: _togglProfile!.clients
              .where((element) =>
                  element.wid == _currentMapping.togglWorkspace?.id)
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
              _currentMapping.togglClient = newValue;
              _currentMapping.togglProject = null;
              _currentMapping.togglTag = null;
            });
          },
        ));
      }

      if (_currentMapping.togglClient != null) {
        var current = _togglProfile?.projects.firstWhereOrNull(
            (element) => element.id == _currentMapping.togglProject?.id);

        widgets.add(DropdownButtonFormField<TogglProject>(
          value: current,
          items: _togglProfile!.projects
              .where((element) =>
                  element.workspaceId == _currentMapping.togglWorkspace?.id)
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
              _currentMapping.togglProject = newValue;
              _currentMapping.togglTag = null;
            });
          },
        ));
      }

      if (_currentMapping.togglProject != null) {
        var current = _togglProfile?.tags.firstWhereOrNull(
            (element) => element.id == _currentMapping.togglTag?.id);

        widgets.add(DropdownButtonFormField<TogglTag>(
          value: current,
          items: _togglProfile!.tags
              .where((element) =>
                  element.workspaceId == _currentMapping.togglWorkspace?.id)
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
              _currentMapping.togglTag = newValue;
            });
          },
        ));
      }

      if (_currentMapping.togglTag != null) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          Row(children: [
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _configuration?.mappings.add(_currentMapping);
                    _currentMapping = ConfigurationMapping();
                    _step = Step.selectProject;
                  });
                },
                child: const Text('Add another')),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _configuration?.mappings.add(_currentMapping);
                    _step = Step.trackingSetup;
                  });
                },
                child: const Text('Next'))
          ]),
        );
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
      _configuration = Configuration([]);
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
      jiraToken = utf8.decode(base64.decode(jiraToken));
      _jiraTokenController.value = TextEditingValue(
        text: jiraToken,
        selection: TextSelection.fromPosition(
          TextPosition(offset: jiraToken.length),
        ),
      );
    } else {
      _jiraTokenController.clear();
    }

    var jiraAuthMethod = _configuration?.jiraAuthMethod;
    if (jiraAuthMethod != null && jiraAuthMethod == 0) {
      _jiraAuthorization = JiraAuthorization.basic;
    } else if (jiraAuthMethod != null && jiraAuthMethod == 1) {
      _jiraAuthorization = JiraAuthorization.bearer;
    } else if (jiraAuthMethod != null && jiraAuthMethod == 2) {
      _jiraAuthorization = JiraAuthorization.cookie;
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
