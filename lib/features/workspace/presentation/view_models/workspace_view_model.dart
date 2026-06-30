import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../../auth/domain/repositories/user_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import '../../../dashboard/domain/repositories/task_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class WorkspaceViewModel extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepository;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  Workspace? _currentWorkspace;
  Workspace? get currentWorkspace => _currentWorkspace;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<User> _members = [];
  List<User> get members => _members;

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  // Stats
  double _overallProgress = 0.0;
  double get overallProgress => _overallProgress;

  int _totalMilestones = 0;
  int get totalMilestones => _totalMilestones;

  int _completedMilestones = 0;
  int get completedMilestones => _completedMilestones;

  List<Milestone> _topMilestones = [];
  List<Milestone> get topMilestones => _topMilestones;

  bool get isAdmin {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null || _currentWorkspace == null) return false;
    
    // Owner is always admin
    if (_currentWorkspace!.ownerId == currentUser.id) return true;
    
    // Check membership role
    try {
      final membership = _members.firstWhere((m) => m.id == currentUser.id);
      return membership.role == 'admin';
    } catch (_) {
      return false;
    }
  }

  StreamSubscription? _workspaceSub;
  StreamSubscription? _projectSub;
  StreamSubscription? _memberSub;
  StreamSubscription? _userSub;
  StreamSubscription? _milestoneSub;
  StreamSubscription? _taskSub;

  WorkspaceViewModel({
    required WorkspaceRepository workspaceRepository,
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
  })  : _workspaceRepository = workspaceRepository,
        _projectRepository = projectRepository,
        _userRepository = userRepository,
        _authRepository = authRepository,
        _milestoneRepository = milestoneRepository,
        _taskRepository = taskRepository {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.initialSession) {
        _init();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _clearData();
      }
    });
  }

  void _clearData() {
    _workspaceSub?.cancel();
    _projectSub?.cancel();
    _memberSub?.cancel();
    _userSub?.cancel();
    _milestoneSub?.cancel();
    _taskSub?.cancel();
    _currentWorkspace = null;
    _projects = [];
    _members = [];
    _allUsers = [];
    _overallProgress = 0.0;
    _totalMilestones = 0;
    _completedMilestones = 0;
    _topMilestones = [];
    notifyListeners();
  }

  void _init() {
    _userSub?.cancel();
    _userSub = _userRepository.watchUsers().listen((data) {
      _allUsers = data;
      notifyListeners();
    });
  }

  void loadWorkspace(String id) async {
    try {
      _workspaceSub?.cancel();
      _workspaceSub = _workspaceRepository.watchWorkspaceById(id).listen((data) {
        _currentWorkspace = data;
        notifyListeners();
      });

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

      _milestoneSub?.cancel();
      _milestoneSub = _milestoneRepository.watchMilestonesByWorkspace(id).listen((data) {
        _totalMilestones = data.length;
        _completedMilestones = data.where((m) => m.progress >= 1.0).length;
        
        // Sorting all milestones by progress descending (most progressed first)
        final sortedMilestones = List<Milestone>.from(data);
        sortedMilestones.sort((a, b) => b.progress.compareTo(a.progress));

        final active = sortedMilestones.where((m) => m.progress < 1.0).toList();
        _topMilestones = active.take(3).toList();
        notifyListeners();
      });

      _taskSub?.cancel();
      _taskSub = _taskRepository.watchTasksByWorkspace(id).listen((data) {
        if (data.isEmpty) {
          _overallProgress = 0.0;
        } else {
          final completed = data.where((t) => t.status == TaskStatus.done).length;
          _overallProgress = completed / data.length;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading workspace: $e');
    }
  }

  Future<String?> _saveImageLocally(String originalPath) async {
    try {
      // إذا كانت الصورة أصلاً من الـ assets لا نفعل شيء
      if (originalPath.startsWith('assets/')) return originalPath;
      
      final File imageFile = File(originalPath);
      if (!imageFile.existsSync()) return originalPath;

      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'ws_${DateTime.now().millisecondsSinceEpoch}${p.extension(originalPath)}';
      final String localPath = p.join(directory.path, fileName);
      
      await imageFile.copy(localPath);
      return localPath;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return originalPath;
    }
  }

  Future<void> createWorkspace(String name, String description, String? imageUrl, List<String> memberIds) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    // حفظ الصورة محلياً أولاً لضمان وجودها أوفلاين
    String? finalImageUrl = imageUrl;
    if (imageUrl != null && !imageUrl.startsWith('assets/')) {
      finalImageUrl = await _saveImageLocally(imageUrl);
    }

    final workspaceId = Uuid().v4();
    final workspace = Workspace(
      id: workspaceId,
      name: name,
      description: description,
      imageUrl: finalImageUrl,
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
    if (!isAdmin) return;
    
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
    if (!isAdmin) return;
    await _workspaceRepository.deleteWorkspace(id);
  }

  Future<void> createProject(String workspaceId, String name, String description, String color) async {
    final project = Project(
      id: Uuid().v4(),
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
    if (!isAdmin) return;
    await _projectRepository.deleteProject(id);
  }

  Future<void> addMember(String workspaceId, String userId) async {
    if (!isAdmin) return;
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
    if (!isAdmin) return;
    await _workspaceRepository.removeMemberFromWorkspace(workspaceId, userId);
  }

  @override
  void dispose() {
    _workspaceSub?.cancel();
    _projectSub?.cancel();
    _memberSub?.cancel();
    _userSub?.cancel();
    _milestoneSub?.cancel();
    _taskSub?.cancel();
    super.dispose();
  }
}
