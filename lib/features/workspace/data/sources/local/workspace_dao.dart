import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'workspace_dao.g.dart';

@DriftAccessor(tables: [Workspaces, WorkspaceMembers])
class WorkspaceDao extends DatabaseAccessor<AppDatabase> with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  // الحصول على نسخة الجدول الفعلية من قاعدة البيانات
  Users get usersTable => attachedDatabase.users;

  Future<int> create(WorkspacesCompanion workspace) => into(workspaces).insert(workspace, mode: InsertMode.insertOrReplace);

  Future<bool> updateEntry(WorkspacesCompanion workspace) async {
    final currentUserId = attachedDatabase.userId;
    if (currentUserId == null) return false;

    final isAdmin = await isUserAdmin(currentUserId, workspace.id.value);
    if (!isAdmin) {
      throw Exception('Security Error: Only admins can update the workspace');
    }
    return update(workspaces).replace(workspace);
  }

  Future<int> softDelete(String id) {
    return (delete(workspaces)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Workspace>> watchAll() {
    return (select(workspaces)).watch();
  }

  /// Get all workspaces where the user is a member (Many-to-Many)
  Stream<List<Workspace>> watchWorkspacesForUser(String userId) {
    // استعلام مباشر: أي مساحة أنا صاحبها أو أنا عضو فيها
    final query = select(workspaces).join([
      leftOuterJoin(workspaceMembers, workspaceMembers.workspaceId.equalsExp(workspaces.id)),
    ])
      ..where(workspaces.ownerId.equals(userId) | workspaceMembers.userId.equals(userId));

    return query.watch().map((rows) {
      final List<Workspace> list = [];
      final Set<String> seenIds = {};
      for (final row in rows) {
        final ws = row.readTable(workspaces);
        if (seenIds.add(ws.id)) {
          list.add(ws);
        }
      }
      return list;
    });
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

  Future<int> removeMember(String workspaceId, String userId) async {
    final currentUserId = attachedDatabase.userId;
    if (currentUserId == null) return 0;

    final isAdmin = await isUserAdmin(currentUserId, workspaceId);
    if (!isAdmin) {
      throw Exception('Security Error: Only admins can remove members');
    }

    return (delete(workspaceMembers)
          ..where((t) => t.workspaceId.equals(workspaceId) & t.userId.equals(userId)))
        .go();
  }

  Future<int> removeAllMembers(String workspaceId) async {
    final currentUserId = attachedDatabase.userId;
    if (currentUserId == null) return 0;

    final isAdmin = await isUserAdmin(currentUserId, workspaceId);
    if (!isAdmin) {
      throw Exception('Security Error: Only admins can remove all members');
    }

    return (delete(workspaceMembers)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .go();
  }

  Future<int> addMember(WorkspaceMembersCompanion member) async {
    final currentUserId = attachedDatabase.userId;
    if (currentUserId == null) return 0;

    // التحقق من وجود أعضاء سابقين
    final existingMembers = await (select(workspaceMembers)
          ..where((t) => t.workspaceId.equals(member.workspaceId.value)))
        .get();

    // السماح بالإضافة إذا كانت المساحة خالية (عند الإنشاء) أو إذا كان المستخدم أدمن
    if (existingMembers.isEmpty) {
      return into(workspaceMembers).insert(member);
    }

    final isAdmin = await isUserAdmin(currentUserId, member.workspaceId.value);
    if (!isAdmin) {
      throw Exception('Security Error: Only admins can add members');
    }
    return into(workspaceMembers).insert(member);
  }

  Stream<List<WorkspaceMember>> watchMembers(String workspaceId) {
    return (select(workspaceMembers)..where((t) => t.workspaceId.equals(workspaceId))).watch();
  }

  // دالة جديدة تقوم بالربط والتحويل داخل الـ DAO لتجنب مشاكل الأنواع
  Stream<List<({WorkspaceMember member, User? user})>> watchMembersWithUsers(String workspaceId) {
    final query = select(workspaceMembers).join([
      leftOuterJoin(attachedDatabase.users, attachedDatabase.users.id.equalsExp(workspaceMembers.userId)),
    ]);
    
    query.where(workspaceMembers.workspaceId.equals(workspaceId));

    return query.watch().map((rows) {
      return rows.map((row) {
        return (
          member: row.readTable(workspaceMembers),
          user: row.readTableOrNull(attachedDatabase.users),
        );
      }).toList();
    });
  }
}
