import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_track_transfer/api/jira/jira_project.dart';
import 'package:time_track_transfer/api/jira/status.dart';
import 'package:time_track_transfer/api/jira/task.dart';
import 'package:time_track_transfer/api/jira_api.dart';
import 'package:time_track_transfer/di.dart';
import 'package:time_track_transfer/main.dart';
import 'package:time_track_transfer/ui/widget/text_styles.dart';
import 'package:time_track_transfer/constants.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

enum Step { setupJira, selectProject, selectStatus }

class _ConfigScreenState extends State<ConfigScreen> {
  final JiraApi _jiraApi = getIt<JiraApi>();

  Step _step = Step.setupJira;

  List<JiraProject>? _jiraProjects;

  JiraProject? _projectSelection;
  String? _jiraProjectId;

  List<Task>? _projectTasks;

  Task? _taskSelection;

  Status? _statusSelection;

  late TextEditingController _jiraEndpointController;
  late TextEditingController _jiraEmailController;
  late TextEditingController _jiraTokenController;

  @override
  void initState() {
    _jiraEndpointController = TextEditingController();
    _jiraEmailController = TextEditingController();
    _jiraTokenController = TextEditingController();

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
      default:
        return [Text("KYP")];
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
              setState(() {
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
        hint: const Text("Select Something"),
        onChanged: (Task? newValue) {
          setState(() {
            _taskSelection = newValue!;
          });
        },
      ),
    );

    if (_taskSelection != null) {
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
          hint: const Text("Select Something"),
          onChanged: (Status? newValue) {
            setState(() {
              _statusSelection = newValue!;
            });
          },
        ),
      );
      children.add(ElevatedButton(
          onPressed: () {
            storage.write(Constants.keyJiraStatus, _statusSelection!.name);
            context.goNamed(RouteName.panel);
          },
          child: const Text('Next')));
    }

    return [
      Column(
        children: children,
      )
    ];
  }

  Future<void> _readStoredState() async {
    var jiraEndpoint = await storage.read(Constants.keyJiraEndpoint);
    var jiraEmail = await storage.read(Constants.keyJiraEmail);
    var jiraToken = await storage.read(Constants.keyJiraToken);
    _jiraProjectId = await storage.read(Constants.keyJiraProjectId);

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
  }
}
