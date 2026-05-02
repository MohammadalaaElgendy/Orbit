import 'package:flutter/material.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepository;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  final List<Milestone> _recentMilestones = [];
  List<Milestone> get recentMilestones => _recentMilestones;

  final List<Task> _recentTasks = [];
  List<Task> get recentTasks => _recentTasks;

  StreamSubscription? _workspaceSub;
  
  DashboardViewModel({
    required WorkspaceRepository workspaceRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
  })  : _workspaceRepository = workspaceRepository {
    _init();
  }

  void _init() {
    _workspaceSub = _workspaceRepository.watchWorkspaces().listen((data) {
      _workspaces = data;
      notifyListeners();
    });
    
    // In a more advanced version, we could watch for "recent" items here using the other repos
  }

  Future<void> createWorkspace(String name, String description, String? imageUrl, List<String> memberIds) async {
    final workspaceId = const Uuid().v4();
    final workspace = Workspace(
      id: workspaceId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _workspaceRepository.createWorkspace(workspace);
    
    for (final userId in memberIds) {
      await _workspaceRepository.addMemberToWorkspace(workspaceId, userId, 'member');
    }
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    await _workspaceRepository.updateWorkspace(workspace);
  }

  Future<void> deleteWorkspace(String id) async {
    await _workspaceRepository.deleteWorkspace(id);
  }

  @override
  void dispose() {
    _workspaceSub?.cancel();
    super.dispose();
  }
}
