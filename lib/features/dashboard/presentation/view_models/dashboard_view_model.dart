import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;
  final AuthRepository _authRepository;

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

  List<Task> _allTasks = [];
  List<Task> get allTasks => _allTasks;

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
  final Map<String, StreamSubscription> _memberSubscriptions = {};
  
  DashboardViewModel({
    required WorkspaceRepository workspaceRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
    required AuthRepository authRepository,
  })  : _workspaceRepository = workspaceRepository,
        _milestoneRepository = milestoneRepository,
        _taskRepository = taskRepository,
        _authRepository = authRepository {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    // إعادة التهيئة فقط إذا تغير المستخدم فعلياً
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final newUser = data.session?.user;
      if (newUser != null) {
        // لا تمسح البيانات إذا كان نفس المستخدم (تجديد توكن مثلاً)
        _init(isNewUser: newUser.id != _authRepository.currentUser?.id);
      } else {
        _clearData();
      }
    });
  }

  void _clearData() {
    _workspaceSub?.cancel();
    _milestoneSub?.cancel();
    _taskSub?.cancel();
    for (var sub in _memberSubscriptions.values) {
      sub.cancel();
    }
    _memberSubscriptions.clear();
    _workspaces = [];
    _workspaceMembersMap.clear();
    _recentMilestones = [];
    _allMilestones = [];
    _recentTasks = [];
    _allTasks = [];
    _overallProgress = 0.0;
    notifyListeners();
  }

  void _init({bool isNewUser = true}) {
    if (isNewUser) {
      _clearData(); 
    }

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    // إلغاء الاشتراكات القديمة قبل البدء بجديد لضمان عدم التكرار
    _workspaceSub?.cancel();
    _milestoneSub?.cancel();
    _taskSub?.cancel();

    // Watch Workspaces
    _workspaceSub = _workspaceRepository.watchWorkspacesForUser(currentUser.id).listen((data) {
      _workspaces = data;
      // ... باقي الكود كما هو
      _updateMemberSubscriptions(data);
      notifyListeners();
    }, onError: (e) => debugPrint('DashboardViewModel: Workspace Stream Error: $e'));

    // ... التحميل لباقي الـ Streams بنفس الطريقة
    _initMilestones();
    _initTasks();
  }

  void _updateMemberSubscriptions(List<Workspace> data) {
      final currentWsIds = data.map((ws) => ws.id).toSet();
      _memberSubscriptions.keys.where((id) => !currentWsIds.contains(id)).toList().forEach((id) {
        _memberSubscriptions[id]?.cancel();
        _memberSubscriptions.remove(id);
        _workspaceMembersMap.remove(id);
      });

      for (var ws in data) {
        if (!_memberSubscriptions.containsKey(ws.id)) {
          _memberSubscriptions[ws.id] = _workspaceRepository.watchWorkspaceMembers(ws.id).listen((members) {
            _workspaceMembersMap[ws.id] = members;
            notifyListeners();
          });
        }
      }
  }

  void _initMilestones() {
    _milestoneSub = _milestoneRepository.watchAllMilestones().listen((data) {
      _allMilestones = data;
      final activeMilestones = data.where((m) => m.progress < 1.0).toList();
      activeMilestones.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      _recentMilestones = activeMilestones.take(5).toList();
      _totalMilestones = data.length;
      _completedMilestones = data.where((m) => m.progress >= 1.0).length;
      final active = data.where((m) => m.progress < 1.0).toList();
      active.sort((a, b) => b.progress.compareTo(a.progress));
      _topMilestones = active.take(3).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('DashboardViewModel: Milestone Stream Error: $e'));
  }

  void _initTasks() {
    _taskSub = _taskRepository.watchAllTasks().listen((data) {
      _allTasks = data;
      _recentTasks = data.take(5).toList();
      if (data.isEmpty) {
        _overallProgress = 0.0;
      } else {
        final completed = data.where((t) => t.status == TaskStatus.done).length;
        _overallProgress = completed / data.length;
      }
      notifyListeners();
    }, onError: (e) => debugPrint('DashboardViewModel: Task Stream Error: $e'));
  }


  Future<void> createWorkspace(String name, String description, String? imageUrl, List<String> memberIds) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    final workspaceId = Uuid().v4();
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
    
    try {
      await _workspaceRepository.createWorkspace(workspace);
      
      for (final userId in memberIds) {
        if (userId != currentUser.id) {
          await _workspaceRepository.addMemberToWorkspace(workspaceId, userId, 'member');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating workspace in DashboardViewModel: $e');
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
    for (var sub in _memberSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
