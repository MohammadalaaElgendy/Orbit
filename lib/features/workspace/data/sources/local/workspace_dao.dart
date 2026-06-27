import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'workspace_dao.g.dart';

@DriftAccessor(tables: [Workspaces, WorkspaceMembers])
class WorkspaceDao extends DatabaseAccessor<AppDatabase> with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  Future<int> create(WorkspacesCompanion workspace) => into(workspaces).insert(workspace, mode: InsertMode.insertOrReplace);

  Future<bool> updateEntry(WorkspacesCompanion workspace) => update(workspaces).replace(workspace);

  Future<int> softDelete(String id) {
    return (delete(workspaces)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Workspace>> watchAll() {
    return (select(workspaces)).watch();
  }

  /// Get all workspaces where the user is a member (Many-to-Many)
  Stream<List<Workspace>> watchWorkspacesForUser(String userId) {
    final query = select(workspaces).join([
      innerJoin(workspaceMembers, workspaceMembers.workspaceId.equalsExp(workspaces.id)),
    ])
      ..where(workspaceMembers.userId.equals(userId));

    return query.watch().map((rows) => rows.map((row) => row.readTable(workspaces)).toList());
  }

  /// Check if a user is an admin in a workspace
  Future<bool> isUserAdmin(String userId, String workspaceId) async {
    final query = select(workspaceMembers)
      ..where((t) =>
          t.userId.equals(userId) &
          t.workspaceId.equals(workspaceId) &
          t.role.equals('admin'));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<Workspace?> getById(String id) {
    return (select(workspaces)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<Workspace?> watchById(String id) {
    return (select(workspaces)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> removeMember(String workspaceId, String userId) {
    return (delete(workspaceMembers)
          ..where((t) => t.workspaceId.equals(workspaceId) & t.userId.equals(userId)))
        .go();
  }

  Future<int> removeAllMembers(String workspaceId) {
    return (delete(workspaceMembers)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .go();
  }

  Future<int> addMember(WorkspaceMembersCompanion member) => into(workspaceMembers).insert(member);

  Stream<List<WorkspaceMember>> watchMembers(String workspaceId) {
    return (select(workspaceMembers)..where((t) => t.workspaceId.equals(workspaceId))).watch();
  }

  Stream<List<TypedResult>> watchMembersWithUsers(String workspaceId) {
    return (select(workspaceMembers)..where((t) => t.workspaceId.equals(workspaceId)))
        .join([
          innerJoin(users, users.id.equalsExp(workspaceMembers.userId)),
        ])
        .watch();
  }
}
