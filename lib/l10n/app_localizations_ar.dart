// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أوربت';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get createWorkspace => 'إنشاء مساحة عمل';

  @override
  String get editWorkspace => 'تعديل مساحة العمل';

  @override
  String get activeWorkspaces => 'مساحات العمل النشطة';

  @override
  String get members => 'الأعضاء';

  @override
  String get activeProjects => 'المشاريع الحالية';

  @override
  String get projectMilestones => 'مراحل المشروع';

  @override
  String get tasks => 'المهام';

  @override
  String get subtasks => 'المهام الفرعية';
}
