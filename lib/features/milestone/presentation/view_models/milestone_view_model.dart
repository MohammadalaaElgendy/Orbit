import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../shared/models/task.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../../workspace/domain/repositories/project_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../dashboard/domain/repositories/task_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';

class MilestoneViewModel extends ChangeNotifier {
  final MilestoneRepository _milestoneRepository;
  final ProjectRepository _projectRepository;
  final WorkspaceRepository _workspaceRepository;
  final TaskRepository _taskRepository;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Milestone? _currentMilestone;
  Milestone? get currentMilestone => _currentMilestone;

  List<User> _workspaceMembers = [];
  List<User> get workspaceMembers => _workspaceMembers;

  bool get isAdmin {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return false;
    
    try {
      final membership = _workspaceMembers.firstWhere((m) => m.id == currentUserId);
      return membership.role == 'admin';
    } catch (_) {
      return false;
    }
  }

  StreamSubscription? _taskSub;
  StreamSubscription? _memberSub;
  StreamSubscription? _milestoneSub;

  MilestoneViewModel({
    required MilestoneRepository milestoneRepository,
    required ProjectRepository projectRepository,
    required WorkspaceRepository workspaceRepository,
    required TaskRepository taskRepository,
  })  : _milestoneRepository = milestoneRepository,
        _projectRepository = projectRepository,
        _workspaceRepository = workspaceRepository,
        _taskRepository = taskRepository {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _clearData();
      }
    });
  }

  void _clearData() {
    _taskSub?.cancel();
    _memberSub?.cancel();
    _milestoneSub?.cancel();
    _tasks = [];
    _currentMilestone = null;
    _workspaceMembers = [];
    notifyListeners();
  }

  void loadMilestoneData(String milestoneId) async {
    _taskSub?.cancel();
    _taskSub = _taskRepository.watchRootTasksByMilestone(milestoneId).listen((data) {
      _tasks = data;
      notifyListeners();
    });

    _milestoneSub?.cancel();
    _milestoneSub = _milestoneRepository.watchMilestoneById(milestoneId).listen((data) {
      _currentMilestone = data;
      notifyListeners();
    });

    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone != null) {
      final project = await _projectRepository.getProjectById(milestone.projectId);
      if (project != null) {
        _memberSub?.cancel();
        _memberSub = _workspaceRepository.watchWorkspaceMembers(project.workspaceId).listen((data) {
          _workspaceMembers = data;
          notifyListeners();
        });
      }
    }
  }

  Stream<List<Milestone>> watchMilestonesByProject(String projectId) {
    return _milestoneRepository.watchMilestonesByProject(projectId);
  }

  Future<void> createMilestone(BuildContext context, String projectId, String name, String description, DateTime? dueDate) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) return;

    final milestone = Milestone(
      id: Uuid().v4(),
      workspaceId: project.workspaceId,
      projectId: projectId,
      name: name,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _milestoneRepository.createMilestone(milestone, project.workspaceId);

    if (dueDate != null && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      await NotificationService().scheduleDeadlineReminders(
        id: milestone.id,
        title: name,
        dayOfBody: l10n.milestoneDeadlineReminderDayOf(name),
        dayBeforeBody: l10n.milestoneDeadlineReminderDayBefore(name),
        deadline: dueDate,
      );
    }
  }

  Future<void> updateMilestone(BuildContext context, Milestone milestone) async {
    try {
      await _milestoneRepository.updateMilestone(milestone);
      
      // تحديث فوري للحالة
      if (_currentMilestone?.id == milestone.id) {
        _currentMilestone = milestone;
      }
      
      notifyListeners();

      if (milestone.dueDate != null && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        await NotificationService().scheduleDeadlineReminders(
          id: milestone.id,
          title: milestone.name,
          dayOfBody: l10n.milestoneDeadlineReminderDayOf(milestone.name),
          dayBeforeBody: l10n.milestoneDeadlineReminderDayBefore(milestone.name),
          deadline: milestone.dueDate!,
        );
      } else {
        await NotificationService().cancelReminders(milestone.id);
      }
    } catch (e) {
      debugPrint('Error updating milestone in ViewModel: $e');
    }
  }

  Future<void> deleteMilestone(String id) async {
    await _milestoneRepository.deleteMilestone(id);
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _memberSub?.cancel();
    _milestoneSub?.cancel();
    super.dispose();
  }
}
