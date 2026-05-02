import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'workspace_dao.g.dart';

@DriftAccessor(tables: [Workspaces, WorkspaceMembers])
class WorkspaceDao extends DatabaseAccessor<AppDatabase> with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  Future<int> create(WorkspacesCompanion workspace) => into(workspaces).insert(workspace);

  Future<bool> updateEntry(WorkspacesCompanion workspace) => update(workspaces).replace(workspace);

  Future<int> softDelete(String id) {
    return (update(workspaces)..where((t) => t.id.equals(id))).write(
      WorkspacesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Stream<List<Workspace>> watchAll() {
    return (select(workspaces)..where((t) => t.deletedAt.isNull())).watch();
  }

  Future<Workspace?> getById(String id) {
    return (select(workspaces)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> removeMember(String workspaceId, String userId) {
    return (delete(workspaceMembers)
          ..where((t) => t.workspaceId.equals(workspaceId) & t.userId.equals(userId)))
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
