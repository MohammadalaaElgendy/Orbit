import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_theme.dart';
import 'core/data/database/app_database.dart';

import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/dashboard/presentation/screens/main_screen.dart';
import 'features/workspace/presentation/screens/workspace_details_screen.dart';
import 'features/milestone/presentation/screens/milestone_details_screen.dart';
import 'features/dashboard/presentation/screens/task_details_screen.dart';

import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/data/sources/remote/supabase_auth_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/workspace/domain/repositories/workspace_repository.dart';
import 'features/workspace/domain/repositories/project_repository.dart';
import 'features/milestone/domain/repositories/milestone_repository.dart';
import 'features/dashboard/domain/repositories/task_repository.dart';

import 'features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'features/workspace/presentation/view_models/workspace_view_model.dart';
import 'features/milestone/presentation/view_models/milestone_view_model.dart';
import 'features/dashboard/presentation/view_models/task_view_model.dart';
import 'features/auth/presentation/view_models/auth_view_model.dart';

import 'l10n/app_localizations.dart';
import 'shared/models/task.dart' as model;
import 'shared/models/workspace.dart' as model;
import 'shared/models/milestone.dart' as model;

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const String supabaseUrl = 'https://ysrahcfgllkkedpwjmjg.supabase.co';
  const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzcmFoY2ZnbGxra2VkcHdqbWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjgzOTcsImV4cCI6MjA5MjcwNDM5N30._kRvAUwM8fM2qN-VL-aOHqlyUuDNwyUPHJKlREAHFuA';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
          ? AuthFlowType.implicit
          : AuthFlowType.pkce,
    ),
  );

  final appLinks = AppLinks();
  // Handle links when app is already running
  appLinks.uriLinkStream.listen((uri) async {
    debugPrint('Received deep link: $uri');
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
  });
  
  // Check for initial link (when app is opened via link)
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    debugPrint('Initial deep link: $initialUri');
    await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
  }

  try {
    await NotificationService().init().timeout(
      const Duration(seconds: 5),
      onTimeout: () => debugPrint('Notification initialization timed out'),
    );
  } catch (e) {
    debugPrint('Error initializing notification service: $e');
  }
  
  final database = AppDatabase();
  final supabaseAuthService = SupabaseAuthService();
  
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == supabase.AuthChangeEvent.signedIn) {
        debugPrint('User signed in via Deep Link');
      }
    });
  }

  final userRepo = UserRepository(database.userDao);
  final authRepo = AuthRepository(supabaseAuthService, userRepo);
  final workspaceRepo = WorkspaceRepository(database.workspaceDao);
  final projectRepo = ProjectRepository(database.projectDao);
  final milestoneRepo = MilestoneRepository(database.milestoneDao);
  final taskRepo = TaskRepository(database.taskDao);

  runApp(OrbitApp(
    database: database,
    userRepo: userRepo,
    authRepo: authRepo,
    workspaceRepo: workspaceRepo,
    projectRepo: projectRepo,
    milestoneRepo: milestoneRepo,
    taskRepo: taskRepo,
  ));
}

class OrbitApp extends StatelessWidget {
  final AppDatabase database;
  final UserRepository userRepo;
  final AuthRepository authRepo;
  final WorkspaceRepository workspaceRepo;
  final ProjectRepository projectRepo;
  final MilestoneRepository milestoneRepo;
  final TaskRepository taskRepo;

  const OrbitApp({
    super.key,
    required this.database,
    required this.userRepo,
    required this.authRepo,
    required this.workspaceRepo,
    required this.projectRepo,
    required this.milestoneRepo,
    required this.taskRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: database),
        Provider.value(value: userRepo),
        Provider.value(value: authRepo),
        Provider.value(value: workspaceRepo),
        Provider.value(value: projectRepo),
        Provider.value(value: milestoneRepo),
        Provider.value(value: taskRepo),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel(authRepository: authRepo)),
        ChangeNotifierProvider(create: (context) => DashboardViewModel(workspaceRepository: workspaceRepo, milestoneRepository: milestoneRepo, taskRepository: taskRepo)),
        ChangeNotifierProvider(create: (context) => WorkspaceViewModel(workspaceRepository: workspaceRepo, projectRepository: projectRepo, userRepository: userRepo)),
        ChangeNotifierProvider(create: (context) => MilestoneViewModel(milestoneRepository: milestoneRepo, projectRepository: projectRepo, workspaceRepository: workspaceRepo, taskRepository: taskRepo)),
        ChangeNotifierProvider(create: (context) => TaskViewModel(taskRepository: taskRepo, milestoneRepository: milestoneRepo, projectRepository: projectRepo, workspaceRepository: workspaceRepo)),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            title: 'Orbit',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const AppScrollBehavior(),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeModel.mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/': return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/welcome': return MaterialPageRoute(builder: (_) => const WelcomeScreen());
                case '/login': return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/register': return MaterialPageRoute(builder: (_) => const RegisterScreen());
                case '/forgot-password': return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
                case '/otp': return MaterialPageRoute(builder: (_) => const OtpScreen());
                case '/dashboard': return MaterialPageRoute(builder: (_) => const MainScreen());
                case '/workspace-details':
                  final workspace = settings.arguments as model.Workspace;
                  return MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => WorkspaceViewModel(workspaceRepository: context.read<WorkspaceRepository>(), projectRepository: context.read<ProjectRepository>(), userRepository: context.read<UserRepository>())..loadWorkspace(workspace.id), child: WorkspaceDetailsScreen(workspace: workspace)));
                case '/milestone-details':
                  final milestone = settings.arguments as model.Milestone;
                  return MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => MilestoneViewModel(milestoneRepository: context.read<MilestoneRepository>(), projectRepository: context.read<ProjectRepository>(), workspaceRepository: context.read<WorkspaceRepository>(), taskRepository: context.read<TaskRepository>())..loadMilestoneData(milestone.id), child: MilestoneDetailsScreen(milestone: milestone)));
                case '/task-details':
                  final task = settings.arguments as model.Task;
                  return MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => TaskViewModel(taskRepository: context.read<TaskRepository>(), milestoneRepository: context.read<MilestoneRepository>(), projectRepository: context.read<ProjectRepository>(), workspaceRepository: context.read<WorkspaceRepository>())..loadTaskDetails(task), child: TaskDetailsScreen(task: task)));
                default: return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}

class ThemeModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  void toggleTheme() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad};
}
