import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_service.dart';
import 'core/data/database/app_database.dart' hide Workspace, Milestone, Task;
import 'core/services/sync_service.dart';
import 'core/services/notification_service.dart';

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
import 'shared/models/workspace.dart';
import 'shared/models/milestone.dart';
import 'shared/models/task.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط مستوى السجلات لكتم الضجيج غير الضروري من PowerSync
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  // تسجيل البروتوكول للديسكتوب لكي يتمكن المتصفح من العودة للتطبيق بعد تسجيل الدخول
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await protocolHandler.register('io.supabase.orbit');
  }
  
  const String supabaseUrl = 'https://ysrahcfgllkkedpwjmjg.supabase.co';
  const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzcmFoY2ZnbGxra2VkcHdqbWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjgzOTcsImV4cCI6MjA5MjcwNDM5N30._kRvAUwM8fM2qN-VL-aOHqlyUuDNwyUPHJKlREAHFuA';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug: true,
  );

  final syncService = SyncService();
  await syncService.initialize();

  // ─── مراقبة حالة الدخول عالمياً لربط المزامنة فوراً ──────────────────────
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.session != null) {
      syncService.connect();
    } else {
      syncService.disconnect();
    }
  });

  await NotificationService().init();

  final database = AppDatabase(syncService.db);
  final supabaseAuthService = SupabaseAuthService();
  final userRepo = UserRepository(database.userDao);
  final authRepo = AuthRepository(supabaseAuthService, userRepo);
  final workspaceRepo = WorkspaceRepository(database.workspaceDao, database.projectDao, database.milestoneDao, database.taskDao);
  final projectRepo = ProjectRepository(database.projectDao);
  final milestoneRepo = MilestoneRepository(database.milestoneDao);
  final taskRepo = TaskRepository(database.taskDao);

  runApp(OrbitApp(
    database: database,
    syncService: syncService,
    userRepo: userRepo,
    authRepo: authRepo,
    workspaceRepo: workspaceRepo,
    projectRepo: projectRepo,
    milestoneRepo: milestoneRepo,
    taskRepo: taskRepo,
    settingsService: settingsService,
  ));
}

class OrbitApp extends StatefulWidget {
  final AppDatabase database;
  final SyncService syncService;
  final UserRepository userRepo;
  final AuthRepository authRepo;
  final WorkspaceRepository workspaceRepo;
  final ProjectRepository projectRepo;
  final MilestoneRepository milestoneRepo;
  final TaskRepository taskRepo;
  final SettingsService settingsService;

  const OrbitApp({
    super.key,
    required this.database,
    required this.syncService,
    required this.userRepo,
    required this.authRepo,
    required this.workspaceRepo,
    required this.projectRepo,
    required this.milestoneRepo,
    required this.taskRepo,
    required this.settingsService,
  });

  @override
  State<OrbitApp> createState() => _OrbitAppState();
}

class _OrbitAppState extends State<OrbitApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // حل مشكلة اختفاء البيانات عند العودة من السكون
    if (state == AppLifecycleState.resumed) {
      debugPrint('Orbit: App resumed, re-activating database connection...');
      // فصل ثم وصل لضمان إعادة تنشيط الـ Isolate والقاعدة المحلية
      widget.syncService.disconnect();
      widget.syncService.connect();
    }
  }

  void _listenToNotifications() {
    NotificationService().onNotificationClick.listen((payload) async {
      if (payload != null) {
        debugPrint('Notification clicked with payload: $payload');
        
        // Try to find if it's a task or milestone
        // First check tasks
        final task = await widget.taskRepo.watchTaskById(payload).first;
        if (task != null) {
          _navigatorKey.currentState?.pushNamed('/task-details', arguments: task);
          return;
        }

        // Then check milestones
        final milestone = await widget.milestoneRepo.watchMilestoneById(payload).first;
        if (milestone != null) {
          _navigatorKey.currentState?.pushNamed('/milestone-details', arguments: milestone);
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.database),
        Provider.value(value: widget.syncService),
        Provider.value(value: widget.userRepo),
        Provider.value(value: widget.authRepo),
        Provider.value(value: widget.workspaceRepo),
        Provider.value(value: widget.projectRepo),
        Provider.value(value: widget.milestoneRepo),
        Provider.value(value: widget.taskRepo),
        Provider.value(value: widget.settingsService),
        ChangeNotifierProvider(create: (_) => ThemeModel(widget.settingsService)),
        ChangeNotifierProvider(create: (_) => LocaleModel(widget.settingsService)),
        ChangeNotifierProvider(create: (context) => AuthViewModel(authRepository: widget.authRepo, syncService: widget.syncService)),
        ChangeNotifierProvider(create: (context) => DashboardViewModel(workspaceRepository: widget.workspaceRepo, milestoneRepository: widget.milestoneRepo, taskRepository: widget.taskRepo, authRepository: widget.authRepo)),
        ChangeNotifierProvider(create: (context) => WorkspaceViewModel(
          workspaceRepository: widget.workspaceRepo, 
          projectRepository: widget.projectRepo, 
          userRepository: widget.userRepo, 
          authRepository: widget.authRepo,
          milestoneRepository: widget.milestoneRepo,
          taskRepository: widget.taskRepo,
        )),
        ChangeNotifierProvider(create: (context) => MilestoneViewModel(milestoneRepository: widget.milestoneRepo, projectRepository: widget.projectRepo, workspaceRepository: widget.workspaceRepo, taskRepository: widget.taskRepo)),
        ChangeNotifierProvider(create: (context) => TaskViewModel(taskRepository: widget.taskRepo, milestoneRepository: widget.milestoneRepo, projectRepository: widget.projectRepo, workspaceRepository: widget.workspaceRepo, authRepository: widget.authRepo)),
      ],
      child: Consumer2<ThemeModel, LocaleModel>(
        builder: (context, themeModel, localeModel, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Orbit',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const AppScrollBehavior(),
            theme: AppTheme.getTheme(themeModel.preset, Brightness.light),
            darkTheme: AppTheme.getTheme(themeModel.preset, Brightness.dark),
            themeMode: themeModel.mode,
            locale: localeModel.locale,
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
                  final workspace = settings.arguments as Workspace;
                  return MaterialPageRoute(builder: (_) => WorkspaceDetailsScreen(workspace: workspace));
                case '/milestone-details':
                  final milestone = settings.arguments as Milestone;
                  return MaterialPageRoute(builder: (_) => MilestoneDetailsScreen(milestone: milestone));
                case '/task-details':
                  final task = settings.arguments as Task;
                  return MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => TaskViewModel(
                        taskRepository: context.read<TaskRepository>(),
                        milestoneRepository: context.read<MilestoneRepository>(),
                        projectRepository: context.read<ProjectRepository>(),
                        workspaceRepository: context.read<WorkspaceRepository>(),
                        authRepository: context.read<AuthRepository>(),
                      ),
                      child: TaskDetailsScreen(task: task),
                    ),
                  );
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
  final SettingsService _settingsService;
  late ThemeMode _mode;
  late ThemePreset _preset;

  ThemeModel(this._settingsService) {
    _mode = _settingsService.getThemeMode();
    _preset = _settingsService.getThemePreset();
  }

  ThemeMode get mode => _mode;
  ThemePreset get preset => _preset;

  void setMode(ThemeMode mode) {
    _mode = mode;
    _settingsService.setThemeMode(mode);
    notifyListeners();
  }

  void setPreset(ThemePreset preset) {
    _preset = preset;
    _settingsService.setThemePreset(preset);
    notifyListeners();
  }

  void toggleTheme() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _settingsService.setThemeMode(_mode);
    notifyListeners();
  }
}

class LocaleModel extends ChangeNotifier {
  final SettingsService _settingsService;
  late Locale? _locale;

  LocaleModel(this._settingsService) {
    _locale = _settingsService.getLocale();
  }

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;
    _settingsService.setLocale(locale);
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    _settingsService.setLocale(null);
    notifyListeners();
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad};
}
