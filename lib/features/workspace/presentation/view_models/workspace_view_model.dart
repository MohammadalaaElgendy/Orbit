import 'package:flutter/material.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/user.dart';
import '../../../auth/domain/repositories/user_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/project_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class WorkspaceViewModel extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepository;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  Workspace? _currentWorkspace;
  Workspace? get currentWorkspace => _currentWorkspace;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<User> _members = [];
  List<User> get members => _members;

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  StreamSubscription? _projectSub;
  StreamSubscription? _memberSub;
  StreamSubscription? _userSub;

  WorkspaceViewModel({
    required WorkspaceRepository workspaceRepository,
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _workspaceRepository = workspaceRepository,
        _projectRepository = projectRepository,
        _userRepository = userRepository,
        _authRepository = authRepository {
    _init();
  }

  void _init() {
    _userSub = _userRepository.watchUsers().listen((data) {
      _allUsers = data;
      notifyListeners();
    });
  }

  void loadWorkspace(String id) async {
    try {
      _currentWorkspace = await _workspaceRepository.getWorkspaceById(id);
      _projectSub?.cancel();
      _projectSub = _projectRepository.watchProjectsByWorkspace(id).listen((data) {
        _projects = data;
        notifyListeners();
      });
      
      _memberSub?.cancel();
      _memberSub = _workspaceRepository.watchWorkspaceMembers(id).listen((data) {
        _members = data;
        notifyListeners();
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading workspace: $e');
    }
  }

  Future<void> createWorkspace(String name, String description, String? imageUrl, List<String> memberIds) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    final workspaceId = const Uuid().v4();
    final workspace = Workspace(
      id: workspaceId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      ownerId: currentUser.id,
      createdBy: currentUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _workspaceRepository.createWorkspace(workspace);
    
    for (final userId in memberIds) {
      if (userId != currentUser.id) {
        await _workspaceRepository.addMemberToWorkspace(workspaceId, userId, 'member');
      }
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
      ownerId: ws.ownerId,
      createdBy: ws.createdBy,
      createdAt: ws.createdAt,
      updatedAt: DateTime.now(),
    );

    // 1. تحديث الحالة في الذاكرة فوراً لسرعة الـ UI
    if (_currentWorkspace?.id == id) {
      _currentWorkspace = updated;
      notifyListeners();
    }

    try {
      // 2. الحفظ في قاعدة البيانات
      await _workspaceRepository.updateWorkspace(updated);

      // Sync Members
      final currentMembersList = await _workspaceRepository.watchWorkspaceMembers(id).first;
      final currentMemberIds = currentMembersList.map((m) => m.id).toSet();
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
    } catch (e) {
      debugPrint('Error updating workspace: $e');
    }
  }

  Future<void> deleteWorkspace(String id) async {
    await _workspaceRepository.deleteWorkspace(id);
  }

  Future<void> createProject(String workspaceId, String name, String description, String color) async {
    final project = Project(
      id: const Uuid().v4(),
      workspaceId: workspaceId,
      name: name,
      description: description,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _projectRepository.createProject(project);
  }

  Future<void> updateProject(Project project) async {
    try {
      // تحديث فوري في قائمة المشاريع المعروضة
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }

      await _projectRepository.updateProject(project);
    } catch (e) {
      debugPrint('Error updating project: $e');
    }
  }

  Future<void> deleteProject(String id) async {
    await _projectRepository.deleteProject(id);
  }

  Future<void> addMember(String workspaceId, String userId) async {
    await _workspaceRepository.addMemberToWorkspace(workspaceId, userId, 'member');
  }

  Future<List<User>> getWorkspaceMembers(String workspaceId) async {
    return _workspaceRepository.watchWorkspaceMembers(workspaceId).first;
  }

  Future<User?> searchUserByEmail(String email) async {
    final localUser = await _userRepository.getUserByEmail(email);
    if (localUser != null) return localUser;

    final remoteResults = await _userRepository.searchUsers(email);
    if (remoteResults.isNotEmpty) {
      return remoteResults.first;
    }
    
    return null;
  }

  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    return _userRepository.searchUsers(query);
  }

  Future<void> removeMember(String workspaceId, String userId) async {
    await _workspaceRepository.removeMemberFromWorkspace(workspaceId, userId);
  }

  @override
  void dispose() {
    _projectSub?.cancel();
    _memberSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }
}
