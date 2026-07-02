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

  @override
  String get workspaceAdmin => 'Workspace Admin';

  @override
  String get member => 'Member';

  @override
  String get close => 'CLOSE';

  @override
  String get secureSignIn => 'SECURE SIGN IN';

  @override
  String get getStarted => 'Get Started';

  @override
  String get emailDescription => 'Enter your email to receive a sign-in code.';

  @override
  String get fullNameLabel => 'Full Name (First time only)';

  @override
  String get fullNameHint => 'Enter your name';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get emailAddressHint => 'Enter your email';

  @override
  String get continueButton => 'Continue';

  @override
  String get sendCodeButton => 'Send Sign-in Code';

  @override
  String get registerAndSendCodeButton => 'Register & Send Code';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get description => 'Description';

  @override
  String get noDescription => 'No description provided yet.';

  @override
  String get priority => 'Priority';

  @override
  String get assignee => 'Assignee';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get dueDate => 'Due Date';

  @override
  String get noSubtasks => 'No subtasks yet';

  @override
  String get workspaces => 'Workspaces';

  @override
  String get milestones => 'Milestones';

  @override
  String get myProfile => 'My Profile';

  @override
  String get priorityMilestones => 'Priority Milestones';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get viewAll => 'View all';

  @override
  String get noWorkspaces => 'No workspaces found';

  @override
  String get total => 'total';

  @override
  String get recent => 'Recent';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get colorThemes => 'Color Themes';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get classicTheme => 'Classic';

  @override
  String get alexandriaTheme => 'Alexandria';

  @override
  String get forestTheme => 'Forest';

  @override
  String get sunsetTheme => 'Sunset';

  @override
  String get sunriseTheme => 'Sunrise';

  @override
  String get lavenderTheme => 'Lavender';

  @override
  String get logout => 'Logout';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get viewDetails => 'VIEW DETAILS';

  @override
  String get noMembers => 'No members yet';

  @override
  String get noProjects => 'No projects yet. Create one to get started!';

  @override
  String get addProject => 'Add Project';

  @override
  String get selectProjectToViewMilestones =>
      'Select a project to view milestones';

  @override
  String get noMilestonesForProject => 'No milestones for this project.';

  @override
  String get addMilestone => 'Add Milestone';

  @override
  String get removeMember => 'Remove Member';

  @override
  String removeMemberConfirm(Object name) {
    return 'Are you sure you want to remove $name from this workspace?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get cancel => 'Cancel';

  @override
  String get focusElevated => 'Your focus, elevated.';

  @override
  String get signInToOrbit => 'Sign In to Orbit';

  @override
  String get editMilestone => 'Edit Milestone';

  @override
  String get newMilestone => 'New Milestone';

  @override
  String get milestoneName => 'Milestone Name';

  @override
  String get milestoneNameHint => 'e.g., MVP Launch';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get descriptionHint => 'What does this milestone achieve?';

  @override
  String get targetDate => 'Target Date';

  @override
  String get setTargetDate => 'Set a target date';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createMilestone => 'Create Milestone';

  @override
  String get editTask => 'Edit Task';

  @override
  String get newTask => 'New Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskTitleHint => 'What needs to be done?';

  @override
  String get pleaseEnterTaskTitle => 'Please enter a task title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get taskDescriptionHint => 'Add some details about this task';

  @override
  String get assigneeLabel => 'Assignee';

  @override
  String get statusLabel => 'Status';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get setDeadline => 'Set a deadline';

  @override
  String get createTask => 'Create Task';

  @override
  String get workspaceName => 'Workspace Name';

  @override
  String get workspaceNameHint => 'e.g., Marketing Team';

  @override
  String get workspaceImage => 'Workspace Image';

  @override
  String get custom => 'Custom';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get enterEmailHint => 'Enter exact email address...';

  @override
  String get userFound => 'User Found';

  @override
  String get selectedMembers => 'Selected Members';

  @override
  String get addMembersStart => 'Add members to start collaborating.';

  @override
  String get editProject => 'Edit Project';

  @override
  String get newProject => 'New Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectNameHint => 'e.g., Mobile App Development';

  @override
  String get pleaseEnterProjectName => 'Please enter a project name';

  @override
  String get projectDescriptionHint => 'Briefly describe the project goals';

  @override
  String get projectThemeColor => 'Project Theme Color';

  @override
  String get addMember => 'Add Member';

  @override
  String get inviteEmailDescription =>
      'Enter the email address of the person you want to invite to this workspace.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterUserEmail => 'Enter user email';

  @override
  String get searchMember => 'Search Member';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get userNotFound => 'User not found in our database.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get add => 'Add';

  @override
  String get noTasksFound => 'No tasks found.';

  @override
  String get totalProductivity => 'Total Productivity';

  @override
  String get done => 'DONE';

  @override
  String get goalProgress => 'GOAL PROGRESS';

  @override
  String get noActiveMilestones => 'No active milestones found.';

  @override
  String tasksCount(Object count) {
    return '$count Tasks';
  }

  @override
  String get verification => 'Verification';

  @override
  String enterCodeSent(Object email) {
    return 'Enter the 6-digit code sent to\n$email';
  }

  @override
  String get otpCode => 'OTP Code';

  @override
  String get verifyAndSignIn => 'Verify & Sign In';

  @override
  String get overdue => 'Overdue';

  @override
  String daysLeft(Object count) {
    return '$count days left';
  }

  @override
  String hoursLeft(Object count) {
    return '$count hours left';
  }

  @override
  String get dueSoon => 'Due soon';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get deadline => 'Deadline';

  @override
  String get noMilestonesFound =>
      'No milestones found.\nBreak down your projects into goals!';

  @override
  String get joinOrbit => 'Join Orbit';

  @override
  String get elevateProductivity => 'Elevate your productivity baseline.';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get password => 'Password';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign In';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetEmailDescription =>
      'Enter your email to receive a reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Reset link sent to your email';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get addTask => 'Add Task';

  @override
  String get noTasksForMilestone => 'No tasks found for this milestone.';

  @override
  String hoursRemaining(Object count) {
    return '$count hours remaining';
  }

  @override
  String daysRemaining(Object count) {
    return '$count days remaining';
  }

  @override
  String get progressLabel => 'Progress';

  @override
  String get deleteWorkspace => 'Delete Workspace';

  @override
  String deleteWorkspaceConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action will hide it from your dashboard.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get editProjectLabel => 'Edit Project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String deleteProjectConfirm(Object name) {
    return 'Are you sure you want to delete project \"$name\"?';
  }

  @override
  String get editTaskLabel => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String deleteTaskConfirm(Object name) {
    return 'Are you sure you want to delete task \"$name\"?';
  }

  @override
  String get deleteMilestone => 'Delete Milestone';

  @override
  String deleteMilestoneConfirm(Object name) {
    return 'Are you sure you want to delete milestone \"$name\"?';
  }

  @override
  String get home => 'Home';

  @override
  String get work => 'Workspaces';

  @override
  String get goals => 'Milestones';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get searchAnything => 'Search anything...';

  @override
  String get searchSuggestions =>
      'Search for workspaces, milestones, and tasks';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get workspace => 'Workspace';

  @override
  String get milestone => 'Milestone';

  @override
  String get task => 'Task';

  @override
  String get statusTodo => 'To Do';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDone => 'Done';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String taskDeadlineReminderDayOf(Object title) {
    return 'Task Deadline Today: $title';
  }

  @override
  String taskDeadlineReminderDayBefore(Object title) {
    return 'Task Deadline Tomorrow: $title';
  }

  @override
  String milestoneDeadlineReminderDayOf(Object title) {
    return 'Milestone Deadline Today: $title';
  }

  @override
  String milestoneDeadlineReminderDayBefore(Object title) {
    return 'Milestone Deadline Tomorrow: $title';
  }
}
