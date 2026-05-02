import 'package:flutter/material.dart';
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

class MilestoneViewModel extends ChangeNotifier {
  final MilestoneRepository _milestoneRepository;
  final ProjectRepository _projectRepository;
  final WorkspaceRepository _workspaceRepository;
  final TaskRepository _taskRepository;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  List<User> _workspaceMembers = [];
  List<User> get workspaceMembers => _workspaceMembers;

  StreamSubscription? _taskSub;
  StreamSubscription? _memberSub;

  MilestoneViewModel({
    required MilestoneRepository milestoneRepository,
    required ProjectRepository projectRepository,
    required WorkspaceRepository workspaceRepository,
    required TaskRepository taskRepository,
  })  : _milestoneRepository = milestoneRepository,
        _projectRepository = projectRepository,
        _workspaceRepository = workspaceRepository,
        _taskRepository = taskRepository;

  void loadMilestoneData(String milestoneId) async {
    _taskSub?.cancel();
    _taskSub = _taskRepository.watchRootTasksByMilestone(milestoneId).listen((data) {
      _tasks = data;
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

  Future<void> createMilestone(String projectId, String name, String description, DateTime? dueDate) async {
    final milestone = Milestone(
      id: const Uuid().v4(),
      projectId: projectId,
      name: name,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _milestoneRepository.createMilestone(milestone);

    if (dueDate != null) {
      await NotificationService().scheduleDeadlineNotification(
        id: milestone.id.hashCode,
        title: 'Milestone Reminder: $name',
        body: 'The deadline for this milestone is in 1 hour.',
        deadline: dueDate,
      );
    }
  }

  Future<void> updateMilestone(Milestone milestone) async {
    await _milestoneRepository.updateMilestone(milestone);

    if (milestone.dueDate != null) {
      await NotificationService().scheduleDeadlineNotification(
        id: milestone.id.hashCode,
        title: 'Milestone Reminder: ${milestone.name}',
        body: 'The deadline for this milestone is in 1 hour.',
        deadline: milestone.dueDate!,
      );
    } else {
      await NotificationService().cancelNotification(milestone.id.hashCode);
    }
  }

  Future<void> deleteMilestone(String id) async {
    await _milestoneRepository.deleteMilestone(id);
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _memberSub?.cancel();
    super.dispose();
  }
}
