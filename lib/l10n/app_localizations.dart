import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Orbit'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get dashboard;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create Workspace'**
  String get createWorkspace;

  /// No description provided for @editWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Edit Workspace'**
  String get editWorkspace;

  /// No description provided for @activeWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Active Workspaces'**
  String get activeWorkspaces;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// No description provided for @projectMilestones.
  ///
  /// In en, this message translates to:
  /// **'Project Milestones'**
  String get projectMilestones;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @workspaceAdmin.
  ///
  /// In en, this message translates to:
  /// **'Workspace Admin'**
  String get workspaceAdmin;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @secureSignIn.
  ///
  /// In en, this message translates to:
  /// **'SECURE SIGN IN'**
  String get secureSignIn;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @emailDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a sign-in code.'**
  String get emailDescription;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name (First time only)'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get fullNameHint;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailAddressHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Sign-in Code'**
  String get sendCodeButton;

  /// No description provided for @registerAndSendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Register & Send Code'**
  String get registerAndSendCodeButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided yet.'**
  String get noDescription;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @assignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @noSubtasks.
  ///
  /// In en, this message translates to:
  /// **'No subtasks yet'**
  String get noSubtasks;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaces;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @priorityMilestones.
  ///
  /// In en, this message translates to:
  /// **'Priority Milestones'**
  String get priorityMilestones;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No workspaces found'**
  String get noWorkspaces;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @colorThemes.
  ///
  /// In en, this message translates to:
  /// **'Color Themes'**
  String get colorThemes;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @classicTheme.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classicTheme;

  /// No description provided for @alexandriaTheme.
  ///
  /// In en, this message translates to:
  /// **'Alexandria'**
  String get alexandriaTheme;

  /// No description provided for @forestTheme.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forestTheme;

  /// No description provided for @sunsetTheme.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunsetTheme;

  /// No description provided for @sunriseTheme.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunriseTheme;

  /// No description provided for @lavenderTheme.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get lavenderTheme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'VIEW DETAILS'**
  String get viewDetails;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembers;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet. Create one to get started!'**
  String get noProjects;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @selectProjectToViewMilestones.
  ///
  /// In en, this message translates to:
  /// **'Select a project to view milestones'**
  String get selectProjectToViewMilestones;

  /// No description provided for @noMilestonesForProject.
  ///
  /// In en, this message translates to:
  /// **'No milestones for this project.'**
  String get noMilestonesForProject;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from this workspace?'**
  String removeMemberConfirm(Object name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @focusElevated.
  ///
  /// In en, this message translates to:
  /// **'Your focus, elevated.'**
  String get focusElevated;

  /// No description provided for @signInToOrbit.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Orbit'**
  String get signInToOrbit;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editMilestone;

  /// No description provided for @newMilestone.
  ///
  /// In en, this message translates to:
  /// **'New Milestone'**
  String get newMilestone;

  /// No description provided for @milestoneName.
  ///
  /// In en, this message translates to:
  /// **'Milestone Name'**
  String get milestoneName;

  /// No description provided for @milestoneNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., MVP Launch'**
  String get milestoneNameHint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What does this milestone achieve?'**
  String get descriptionHint;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @setTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Set a target date'**
  String get setTargetDate;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @createMilestone.
  ///
  /// In en, this message translates to:
  /// **'Create Milestone'**
  String get createMilestone;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskTitleHint;

  /// No description provided for @pleaseEnterTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task title'**
  String get pleaseEnterTaskTitle;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add some details about this task'**
  String get taskDescriptionHint;

  /// No description provided for @assigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assigneeLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @setDeadline.
  ///
  /// In en, this message translates to:
  /// **'Set a deadline'**
  String get setDeadline;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace Name'**
  String get workspaceName;

  /// No description provided for @workspaceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Marketing Team'**
  String get workspaceNameHint;

  /// No description provided for @workspaceImage.
  ///
  /// In en, this message translates to:
  /// **'Workspace Image'**
  String get workspaceImage;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter exact email address...'**
  String get enterEmailHint;

  /// No description provided for @userFound.
  ///
  /// In en, this message translates to:
  /// **'User Found'**
  String get userFound;

  /// No description provided for @selectedMembers.
  ///
  /// In en, this message translates to:
  /// **'Selected Members'**
  String get selectedMembers;

  /// No description provided for @addMembersStart.
  ///
  /// In en, this message translates to:
  /// **'Add members to start collaborating.'**
  String get addMembersStart;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Mobile App Development'**
  String get projectNameHint;

  /// No description provided for @pleaseEnterProjectName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a project name'**
  String get pleaseEnterProjectName;

  /// No description provided for @projectDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the project goals'**
  String get projectDescriptionHint;

  /// No description provided for @projectThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Project Theme Color'**
  String get projectThemeColor;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @inviteEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address of the person you want to invite to this workspace.'**
  String get inviteEmailDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter user email'**
  String get enterUserEmail;

  /// No description provided for @searchMember.
  ///
  /// In en, this message translates to:
  /// **'Search Member'**
  String get searchMember;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found in our database.'**
  String get userNotFound;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found.'**
  String get noTasksFound;

  /// No description provided for @totalProductivity.
  ///
  /// In en, this message translates to:
  /// **'Total Productivity'**
  String get totalProductivity;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'GOAL PROGRESS'**
  String get goalProgress;

  /// No description provided for @noActiveMilestones.
  ///
  /// In en, this message translates to:
  /// **'No active milestones found.'**
  String get noActiveMilestones;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Tasks'**
  String tasksCount(Object count);

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @enterCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to\n{email}'**
  String enterCodeSent(Object email);

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @verifyAndSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify & Sign In'**
  String get verifyAndSignIn;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(Object count);

  /// No description provided for @hoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} hours left'**
  String hoursLeft(Object count);

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get dueSoon;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortBy;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @noMilestonesFound.
  ///
  /// In en, this message translates to:
  /// **'No milestones found.\nBreak down your projects into goals!'**
  String get noMilestonesFound;

  /// No description provided for @joinOrbit.
  ///
  /// In en, this message translates to:
  /// **'Join Orbit'**
  String get joinOrbit;

  /// No description provided for @elevateProductivity.
  ///
  /// In en, this message translates to:
  /// **'Elevate your productivity baseline.'**
  String get elevateProductivity;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get resetEmailDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @noTasksForMilestone.
  ///
  /// In en, this message translates to:
  /// **'No tasks found for this milestone.'**
  String get noTasksForMilestone;

  /// No description provided for @hoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} hours remaining'**
  String hoursRemaining(Object count);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(Object count);

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @deleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Delete Workspace'**
  String get deleteWorkspace;

  /// No description provided for @deleteWorkspaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action will hide it from your dashboard.'**
  String deleteWorkspaceConfirm(Object name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProjectLabel;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProject;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete project \"{name}\"?'**
  String deleteProjectConfirm(Object name);

  /// No description provided for @editTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskLabel;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete task \"{name}\"?'**
  String deleteTaskConfirm(Object name);

  /// No description provided for @deleteMilestone.
  ///
  /// In en, this message translates to:
  /// **'Delete Milestone'**
  String get deleteMilestone;

  /// No description provided for @deleteMilestoneConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete milestone \"{name}\"?'**
  String deleteMilestoneConfirm(Object name);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
