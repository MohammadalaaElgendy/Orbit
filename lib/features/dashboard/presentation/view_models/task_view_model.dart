import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../core/services/notification_service.dart';
import '../../../../shared/view_models/base_view_model.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import '../../../workspace/domain/repositories/project_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';

class TaskViewModel extends BaseViewModel {
  final TaskRepository _taskRepository;
  final MilestoneRepository _milestoneRepository;
  final ProjectRepository _projectRepository;
  final WorkspaceRepository _workspaceRepository;
  final AuthRepository _authRepository;

  Task? _currentTask;
  Task? get currentTask => _currentTask;

  List<Task> _subtasks = [];
  List<Task> get subtasks => _subtasks;

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

  TaskViewModel({
    required TaskRepository taskRepository,
    required MilestoneRepository milestoneRepository,
    required ProjectRepository projectRepository,
    required WorkspaceRepository workspaceRepository,
    required AuthRepository authRepository,
  })  : _taskRepository = taskRepository,
        _milestoneRepository = milestoneRepository,
        _projectRepository = projectRepository,
        _workspaceRepository = workspaceRepository,
        _authRepository = authRepository;

  @override
  void onLoggedOut() {
    _currentTask = null;
    _subtasks = [];
    _workspaceMembers = [];
    super.onLoggedOut();
  }

  void loadTaskDetails(Task task) async {
    if (_currentTask?.id == task.id) return;
    _currentTask = task;
    
    clearSubscriptions(); // Clears previous task/member subs
    
    addSubscription(_taskRepository.watchTaskById(task.id).listen((data) {
      if (data != null) {
        _currentTask = data;
        notifyListeners();
      }
    }));

    addSubscription(_taskRepository.watchSubtasks(task.id).listen((data) {
      _subtasks = data;
      notifyListeners();
    }));

    final milestone = await _milestoneRepository.getMilestoneById(task.milestoneId);
    if (milestone != null) {
      final project = await _projectRepository.getProjectById(milestone.projectId);
      if (project != null) {
        addSubscription(_workspaceRepository.watchWorkspaceMembers(project.workspaceId).listen((data) {
          _workspaceMembers = data;
          notifyListeners();
        }));
      }
    }
    notifyListeners();
  }

  Future<void> createTask({
    required BuildContext context,
    required String milestoneId,
    String? workspaceId, // أضفنا هذا لزيادة الثبات
    String? parentTaskId,
    required String title,
    required String description,
    String? assigneeId,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.todo,
    DateTime? dueDate,
  }) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    String? finalWorkspaceId = workspaceId;

    // إذا لم يتم توفير معرف مساحة العمل، نحاول جلبه من الداتابيز
    if (finalWorkspaceId == null) {
      final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
      if (milestone == null) {
        debugPrint('TaskViewModel: Cannot create task because milestone $milestoneId was not found locally.');
        return;
      }
      finalWorkspaceId = milestone.workspaceId;
    }

    // Subtask inheritance logic: Inherit assignee from parent if not specified
    String? finalAssigneeId = assigneeId;
    if (parentTaskId != null && finalAssigneeId == null) {
      final parentTask = await _taskRepository.getTaskById(parentTaskId);
      if (parentTask != null) {
        finalAssigneeId = parentTask.assigneeId;
      }
    }

    // Auto-assign logic for members (only if still unassigned)
    if (finalAssigneeId == null) {
      try {
        List<User> members = _workspaceMembers;
        if (members.isEmpty) {
          members = await _workspaceRepository.watchWorkspaceMembers(finalWorkspaceId).first;
        }
        
        final membership = members.firstWhere((m) => m.id == currentUser.id);
        if (membership.role != 'admin') {
          finalAssigneeId = currentUser.id;
        }
      } catch (_) {
        // Fallback if role can't be determined
      }
    }

    final task = Task(
      id: Uuid().v4(),
      workspaceId: finalWorkspaceId,
      milestoneId: milestoneId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      assigneeId: finalAssigneeId,
      createdBy: currentUser.id,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      await _taskRepository.createTask(task, finalWorkspaceId);
      notifyListeners();

      if (dueDate != null && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        await NotificationService().scheduleDeadlineReminders(
          id: task.id,
          title: title,
          dayOfBody: l10n.taskDeadlineReminderDayOf(title),
          dayBeforeBody: l10n.taskDeadlineReminderDayBefore(title),
          deadline: dueDate,
        );
      }
    } catch (e) {
      debugPrint('Error creating task: $e');
    }
  }

  Future<void> updateTask(BuildContext context, Task task) async {
    try {
      // 1. تحديث قاعدة البيانات محلياً (Offline-First)
      await _taskRepository.updateTask(task);

      // 2. تحديث الحالة في الـ ViewModel فوراً لضمان سرعة الواجهة
      if (_currentTask?.id == task.id) {
        _currentTask = task;
      }
      
      // تحديث المهمة في قائمة الـ subtasks إذا كانت موجودة
      final index = _subtasks.indexWhere((st) => st.id == task.id);
      if (index != -1) {
        _subtasks[index] = task;
      }

      // Cascade assignee change to all loaded subtasks in memory
      for (int i = 0; i < _subtasks.length; i++) {
        if (_subtasks[i].parentTaskId == task.id) {
          _subtasks[i] = _subtasks[i].copyWith(assigneeId: task.assigneeId);
        }
      }

      notifyListeners();

      // 3. جدولة التنبيهات في الخلفية
      if (task.dueDate != null && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        await NotificationService().scheduleDeadlineReminders(
          id: task.id,
          title: task.title,
          dayOfBody: l10n.taskDeadlineReminderDayOf(task.title),
          dayBeforeBody: l10n.taskDeadlineReminderDayBefore(task.title),
          deadline: task.dueDate!,
        );
      } else {
        await NotificationService().cancelReminders(task.id);
      }
    } catch (e) {
      debugPrint('Error updating task in ViewModel: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
  }
}
