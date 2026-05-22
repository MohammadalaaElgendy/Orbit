import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import '../../../workspace/domain/repositories/project_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class TaskViewModel extends ChangeNotifier {
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

  StreamSubscription? _taskSub;
  StreamSubscription? _subtaskSub;
  StreamSubscription? _memberSub;

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

  void loadTaskDetails(Task task) async {
    _currentTask = task;
    
    _taskSub?.cancel();
    _taskSub = _taskRepository.watchTaskById(task.id).listen((data) {
      if (data != null) {
        _currentTask = data;
        notifyListeners();
      }
    });

    _subtaskSub?.cancel();
    _subtaskSub = _taskRepository.watchSubtasks(task.id).listen((data) {
      _subtasks = data;
      notifyListeners();
    });

    final milestone = await _milestoneRepository.getMilestoneById(task.milestoneId);
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
    notifyListeners();
  }

  Future<void> createTask({
    required String milestoneId,
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

    final task = Task(
      id: const Uuid().v4(),
      milestoneId: milestoneId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      assigneeId: assigneeId,
      createdBy: currentUser.id,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _taskRepository.createTask(task);

    if (dueDate != null) {
      await NotificationService().scheduleDeadlineNotification(
        id: task.id.hashCode,
        title: 'Task Reminder: $title',
        body: 'The deadline for this task is in 1 hour.',
        deadline: dueDate,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.updateTask(task);

    if (task.dueDate != null) {
      await NotificationService().scheduleDeadlineNotification(
        id: task.id.hashCode,
        title: 'Task Reminder: ${task.title}',
        body: 'The deadline for this task is in 1 hour.',
        deadline: task.dueDate!,
      );
    } else {
      await NotificationService().cancelNotification(task.id.hashCode);
    }

    if (_currentTask?.id == task.id) {
      _currentTask = task;
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _subtaskSub?.cancel();
    _memberSub?.cancel();
    super.dispose();
  }
}
