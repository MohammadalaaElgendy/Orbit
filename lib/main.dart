import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/workspace/presentation/screens/workspace_details_screen.dart';
import 'features/milestone/presentation/screens/milestone_details_screen.dart';
import 'features/dashboard/presentation/screens/task_details_screen.dart';
import 'shared/models/task.dart';
import 'shared/models/workspace.dart';
import 'shared/models/milestone.dart';

void main() {
  runApp(const OrbitApp());
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider setup for Phase 1 (mainly UI/Theme state if needed)
        ChangeNotifierProvider(create: (_) => ThemeModel()),
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
                  final workspace = settings.arguments as Workspace;
                  return MaterialPageRoute(builder: (_) => WorkspaceDetailsScreen(workspace: workspace));
                case '/milestone-details':
                  final milestone = settings.arguments as Milestone;
                  return MaterialPageRoute(builder: (_) => MilestoneDetailsScreen(milestone: milestone));
                case '/task-details':
                  final task = settings.arguments as Task;
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
