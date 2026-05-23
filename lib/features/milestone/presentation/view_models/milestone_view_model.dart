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

  Milestone? _currentMilestone;
  Milestone? get currentMilestone => _currentMilestone;

  List<User> _workspaceMembers = [];
  List<User> get workspaceMembers => _workspaceMembers;

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
        _taskRepository = taskRepository;

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

  Future<void> createMilestone(String projectId, String name, String description, DateTime? dueDate) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) return;

    final milestone = Milestone(
      id: const Uuid().v4(),
      workspaceId: project.workspaceId,
      projectId: projectId,
      name: name,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _milestoneRepository.createMilestone(milestone, project.workspaceId);

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
    try {
      await _milestoneRepository.updateMilestone(milestone);
      
      // تحديث فوري للحالة
      if (_currentMilestone?.id == milestone.id) {
        _currentMilestone = milestone;
      }
      
      // تحديث في القائمة
      final index = _tasks.indexWhere((t) => t.id == milestone.id);
      if (index != -1) {
        // ... (This is for tasks list, but logic is same)
      }
      
      notifyListeners();

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
