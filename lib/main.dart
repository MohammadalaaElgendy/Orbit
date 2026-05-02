import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/data/database/app_database.dart';
import 'core/data/database/database_seeder.dart';

import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/workspace/presentation/screens/workspace_details_screen.dart';
import 'features/milestone/presentation/screens/milestone_details_screen.dart';
import 'features/dashboard/presentation/screens/task_details_screen.dart';

import 'features/auth/domain/repositories/user_repository.dart';
import 'features/workspace/domain/repositories/workspace_repository.dart';
import 'features/workspace/domain/repositories/project_repository.dart';
import 'features/milestone/domain/repositories/milestone_repository.dart';
import 'features/dashboard/domain/repositories/task_repository.dart';

import 'features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'features/workspace/presentation/view_models/workspace_view_model.dart';
import 'features/milestone/presentation/view_models/milestone_view_model.dart';
import 'features/dashboard/presentation/view_models/task_view_model.dart';

import 'shared/models/task.dart' as model;
import 'shared/models/workspace.dart' as model;
import 'shared/models/milestone.dart' as model;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = AppDatabase();
  
  // Initialize Repositories
  final userRepo = UserRepository(database.userDao);
  final workspaceRepo = WorkspaceRepository(database.workspaceDao);
  final projectRepo = ProjectRepository(database.projectDao);
  final milestoneRepo = MilestoneRepository(database.milestoneDao);
  final taskRepo = TaskRepository(database.taskDao);

  // Seed Data
  await DatabaseSeeder.seed(
    database,
    userRepo,
    workspaceRepo,
    projectRepo,
    milestoneRepo,
    taskRepo,
  );

  runApp(OrbitApp(
    database: database,
    userRepo: userRepo,
    workspaceRepo: workspaceRepo,
    projectRepo: projectRepo,
    milestoneRepo: milestoneRepo,
    taskRepo: taskRepo,
  ));
}

class OrbitApp extends StatelessWidget {
  final AppDatabase database;
  final UserRepository userRepo;
  final WorkspaceRepository workspaceRepo;
  final ProjectRepository projectRepo;
  final MilestoneRepository milestoneRepo;
  final TaskRepository taskRepo;

  const OrbitApp({
    super.key,
    required this.database,
    required this.userRepo,
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
        Provider.value(value: workspaceRepo),
        Provider.value(value: projectRepo),
        Provider.value(value: milestoneRepo),
        Provider.value(value: taskRepo),
        
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            workspaceRepository: workspaceRepo,
            milestoneRepository: milestoneRepo,
            taskRepository: taskRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkspaceViewModel(
            workspaceRepository: workspaceRepo,
            projectRepository: projectRepo,
            userRepository: userRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MilestoneViewModel(
            milestoneRepository: milestoneRepo,
            projectRepository: projectRepo,
            workspaceRepository: workspaceRepo,
            taskRepository: taskRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskViewModel(
            taskRepository: taskRepo,
            milestoneRepository: milestoneRepo,
            projectRepository: projectRepo,
            workspaceRepository: workspaceRepo,
          ),
        ),
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
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/welcome':
                  return MaterialPageRoute(builder: (_) => const WelcomeScreen());
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/register':
                  return MaterialPageRoute(builder: (_) => const RegisterScreen());
                case '/forgot-password':
                  return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
                case '/dashboard':
                  return MaterialPageRoute(builder: (_) => const DashboardScreen());
                case '/workspace-details':
                  final workspace = settings.arguments as model.Workspace;
                  return MaterialPageRoute(builder: (_) => WorkspaceDetailsScreen(workspace: workspace));
                case '/milestone-details':
                  final milestone = settings.arguments as model.Milestone;
                  return MaterialPageRoute(builder: (_) => MilestoneDetailsScreen(milestone: milestone));
                case '/task-details':
                  final task = settings.arguments as model.Task;
                  return MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task));
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
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
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
