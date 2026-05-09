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
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  final Map<String, List<User>> _workspaceMembersMap = {};
  Map<String, List<User>> get workspaceMembersMap => _workspaceMembersMap;

  List<Milestone> _recentMilestones = [];
  List<Milestone> get recentMilestones => _recentMilestones;

  List<Milestone> _allMilestones = [];
  List<Milestone> get allMilestones => _allMilestones;

  List<Task> _recentTasks = [];
  List<Task> get recentTasks => _recentTasks;

  // Stats
  double _overallProgress = 0.0;
  double get overallProgress => _overallProgress;

  int _totalMilestones = 0;
  int get totalMilestones => _totalMilestones;

  int _completedMilestones = 0;
  int get completedMilestones => _completedMilestones;

  List<Milestone> _topMilestones = [];
  List<Milestone> get topMilestones => _topMilestones;

  StreamSubscription? _workspaceSub;
  StreamSubscription? _milestoneSub;
  StreamSubscription? _taskSub;
  
  DashboardViewModel({
    required WorkspaceRepository workspaceRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
  })  : _workspaceRepository = workspaceRepository,
        _milestoneRepository = milestoneRepository,
        _taskRepository = taskRepository {
    _init();
  }

  void _init() {
    // Watch Workspaces
    _workspaceSub = _workspaceRepository.watchWorkspaces().listen((data) async {
      _workspaces = data;
      for (var ws in data) {
        final members = await _workspaceRepository.watchWorkspaceMembers(ws.id).first;
        _workspaceMembersMap[ws.id] = members;
      }
      notifyListeners();
    });

    // Watch ALL Milestones - Ensure this is robust
    _milestoneSub = _milestoneRepository.watchAllMilestones().listen((data) {
      _allMilestones = data;
      _recentMilestones = data.take(5).toList();
      _totalMilestones = data.length;
      _completedMilestones = data.where((m) => m.progress >= 1.0).length;
      
      final active = data.where((m) => m.progress < 1.0).toList();
      active.sort((a, b) => b.progress.compareTo(a.progress));
      _topMilestones = active.take(3).toList();
      
      notifyListeners();
    });

    _taskSub = _taskRepository.watchAllTasks().listen((data) {
      _recentTasks = data.take(10).toList();
      
      if (data.isEmpty) {
        _overallProgress = 0.0;
      } else {
        final completed = data.where((t) => t.status == TaskStatus.done).length;
        _overallProgress = completed / data.length;
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
    _milestoneSub?.cancel();
    _taskSub?.cancel();
    super.dispose();
  }
}
