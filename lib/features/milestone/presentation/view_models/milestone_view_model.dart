import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../shared/view_models/base_view_model.dart';
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

class MilestoneViewModel extends BaseViewModel {
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
      return membership.isAdmin;
    } catch (_) {
      return false;
    }
  }

  MilestoneViewModel({
    required MilestoneRepository milestoneRepository,
    required ProjectRepository projectRepository,
    required WorkspaceRepository workspaceRepository,
    required TaskRepository taskRepository,
  })  : _milestoneRepository = milestoneRepository,
        _projectRepository = projectRepository,
        _workspaceRepository = workspaceRepository,
        _taskRepository = taskRepository;

  @override
  void onLoggedOut() {
    _tasks = [];
    _currentMilestone = null;
    _workspaceMembers = [];
    super.onLoggedOut();
  }

  void loadMilestoneData(String milestoneId) async {
    if (_currentMilestone?.id == milestoneId) return;

    clearSubscriptions();

    addSubscription(_taskRepository.watchRootTasksByMilestone(milestoneId).listen((data) {
      _tasks = data;
      notifyListeners();
    }));

    addSubscription(_milestoneRepository.watchMilestoneById(milestoneId).listen((data) {
      _currentMilestone = data;
      notifyListeners();
    }));

    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone != null) {
      final project = await _projectRepository.getProjectById(milestone.projectId);
      if (project != null) {
        addSubscription(_workspaceRepository.watchWorkspaceMembers(project.workspaceId).listen((data) {
          _workspaceMembers = data;
          notifyListeners();
        }));
      }
    }
  }

  Stream<List<Milestone>> watchMilestonesByProject(String projectId) {
    return _milestoneRepository.watchMilestonesByProject(projectId);
  }

  Future<void> createMilestone(BuildContext context, String projectId, String name, String description, DateTime? dueDate, {String? workspaceId}) async {
    String? finalWorkspaceId = workspaceId;

    if (finalWorkspaceId == null) {
      final project = await _projectRepository.getProjectById(projectId);
      if (project == null) {
        debugPrint('MilestoneViewModel: Cannot create milestone because project $projectId was not found locally.');
        return;
      }
      finalWorkspaceId = project.workspaceId;
    }

    final milestone = Milestone(
      id: Uuid().v4(),
      workspaceId: finalWorkspaceId,
      projectId: projectId,
      name: name,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      await _milestoneRepository.createMilestone(milestone, finalWorkspaceId);
      notifyListeners();

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
    } catch (e) {
      debugPrint('Error creating milestone: $e');
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
}
