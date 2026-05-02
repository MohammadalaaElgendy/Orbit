// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orbit';

  @override
  String get dashboard => 'My Dashboard';

  @override
  String get createWorkspace => 'Create Workspace';

  @override
  String get editWorkspace => 'Edit Workspace';

  @override
  String get activeWorkspaces => 'Active Workspaces';

  @override
  String get members => 'Members';

  @override
  String get activeProjects => 'Active Projects';

  @override
  String get projectMilestones => 'Project Milestones';

  @override
  String get tasks => 'Tasks';

  @override
  String get subtasks => 'Subtasks';
}
