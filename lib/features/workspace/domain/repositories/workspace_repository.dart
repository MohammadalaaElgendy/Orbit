import '../../../../shared/models/workspace.dart' as model;
import '../../../../shared/models/user.dart' as model;
import '../../data/sources/local/workspace_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class WorkspaceRepository {
  final WorkspaceDao _workspaceDao;

  WorkspaceRepository(this._workspaceDao);

  Future<void> createWorkspace(model.Workspace workspace) async {
    await _workspaceDao.create(db.WorkspacesCompanion(
      id: Value(workspace.id),
      name: Value(workspace.name),
      description: Value(workspace.description),
      imageUrl: Value(workspace.imageUrl),
      ownerId: Value(workspace.ownerId),
      createdBy: Value(workspace.createdBy),
      createdAt: Value(workspace.createdAt.toIso8601String()),
      updatedAt: Value(workspace.updatedAt.toIso8601String()),
    ));
    
    // Also add the creator as an admin automatically
    await addMemberToWorkspace(workspace.id, workspace.createdBy, 'admin');
  }

  Stream<List<model.Workspace>> watchWorkspacesForUser(String userId) {
    return _workspaceDao.watchWorkspacesForUser(userId).map((rows) => rows
        .map((row) => model.Workspace(
              id: row.id,
              name: row.name,
              description: row.description,
              imageUrl: row.imageUrl,
              ownerId: row.ownerId,
              createdBy: row.createdBy,
              createdAt: DateTime.parse(row.createdAt),
              updatedAt: DateTime.parse(row.updatedAt),
            ))
        .toList());
  }

  Future<model.Workspace?> getWorkspaceById(String id) async {
    final row = await _workspaceDao.getById(id);
    if (row == null) return null;
    return model.Workspace(
      id: row.id,
      name: row.name,
      description: row.description,
      imageUrl: row.imageUrl,
      ownerId: row.ownerId,
      createdBy: row.createdBy,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }

  Future<void> updateWorkspace(model.Workspace workspace) async {
    await _workspaceDao.updateEntry(db.WorkspacesCompanion(
      id: Value(workspace.id),
      name: Value(workspace.name),
      description: Value(workspace.description),
      imageUrl: Value(workspace.imageUrl),
      ownerId: Value(workspace.ownerId),
      createdBy: Value(workspace.createdBy),
      createdAt: Value(workspace.createdAt.toIso8601String()),
      updatedAt: Value(DateTime.now().toIso8601String()),
    ));
  }

  Future<void> deleteWorkspace(String id) async {
    await _workspaceDao.softDelete(id);
  }

  Future<void> addMemberToWorkspace(String workspaceId, String userId, String role) async {
    await _workspaceDao.addMember(db.WorkspaceMembersCompanion(
      id: Value(const Uuid().v4()),
      workspaceId: Value(workspaceId),
      userId: Value(userId),
      role: Value(role),
      createdAt: Value(DateTime.now().toUtc().toIso8601String()),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<void> removeMemberFromWorkspace(String workspaceId, String userId) async {
    await _workspaceDao.removeMember(workspaceId, userId);
  }

  Stream<List<model.User>> watchWorkspaceMembers(String workspaceId) {
    return _workspaceDao.watchMembersWithUsers(workspaceId).map((rows) {
      return rows.map((row) {
        final user = row.readTable(_workspaceDao.users);
        final membership = row.readTable(_workspaceDao.workspaceMembers);
        return model.User(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
          role: membership.role, // ربط الرتبة هنا
        );
      }).toList();
    });
  }
}
