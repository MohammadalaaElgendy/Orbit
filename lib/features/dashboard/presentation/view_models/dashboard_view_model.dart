import 'package:flutter/material.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepository;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  final Map<String, List<User>> _workspaceMembersMap = {};
  Map<String, List<User>> get workspaceMembersMap => _workspaceMembersMap;

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
    _workspaceSub = _workspaceRepository.watchWorkspaces().listen((data) async {
      _workspaces = data;
      
      // Fetch members for each workspace to show real avatars on cards
      for (var ws in data) {
        final members = await _workspaceRepository.watchWorkspaceMembers(ws.id).first;
        _workspaceMembersMap[ws.id] = members;
      }
      
      notifyListeners();
    });
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

  Future<void> updateWorkspace(String id, String name, String description, String? imageUrl, List<String> memberIds) async {
    final ws = await _workspaceRepository.getWorkspaceById(id);
    if (ws == null) return;
    
    final updated = Workspace(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl ?? ws.imageUrl,
      createdAt: ws.createdAt,
      updatedAt: DateTime.now(),
    );
    await _workspaceRepository.updateWorkspace(updated);

    // Sync Members
    final currentMembers = await _workspaceRepository.watchWorkspaceMembers(id).first;
    final currentMemberIds = currentMembers.map((m) => m.id).toSet();
    final newMemberIds = memberIds.toSet();

    for (final mId in currentMemberIds) {
      if (!newMemberIds.contains(mId)) {
        await _workspaceRepository.removeMemberFromWorkspace(id, mId);
      }
    }

    for (final mId in newMemberIds) {
      if (!currentMemberIds.contains(mId)) {
        await _workspaceRepository.addMemberToWorkspace(id, mId, 'member');
      }
    }

    notifyListeners();
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
