import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<int> create(ProjectsCompanion project) => into(projects).insert(project);

  Future<bool> updateEntry(ProjectsCompanion project) => update(projects).replace(project);

  Future<int> softDelete(String id) {
    return (delete(projects)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Project>> watchAll() {
    return (select(projects)).watch();
  }

  Stream<List<Project>> watchByWorkspace(String workspaceId) {
    return (select(projects)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .watch();
  }

  Future<Project?> getById(String id) {
    return (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> softDeleteByWorkspace(String workspaceId) {
    return (delete(projects)..where((t) => t.workspaceId.equals(workspaceId))).go();
  }
}
