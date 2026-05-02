import '../../../../shared/models/project.dart' as model;
import '../../data/sources/local/project_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class ProjectRepository {
  final ProjectDao _projectDao;

  ProjectRepository(this._projectDao);

  Future<void> createProject(model.Project project) async {
    await _projectDao.create(db.ProjectsCompanion(
      id: Value(project.id),
      workspaceId: Value(project.workspaceId),
      name: Value(project.name),
      description: Value(project.description),
      color: Value(project.color),
      createdAt: Value(project.createdAt),
      updatedAt: Value(project.updatedAt),
    ));
  }

  Stream<List<model.Project>> watchProjectsByWorkspace(String workspaceId) {
    return _projectDao.watchByWorkspace(workspaceId).map((rows) => rows
        .map((row) => model.Project(
              id: row.id,
              workspaceId: row.workspaceId,
              name: row.name,
              description: row.description,
              color: row.color,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ))
        .toList());
  }

  Future<void> updateProject(model.Project project) async {
    await _projectDao.updateEntry(db.ProjectsCompanion(
      id: Value(project.id),
      workspaceId: Value(project.workspaceId),
      name: Value(project.name),
      description: Value(project.description),
      color: Value(project.color),
      createdAt: Value(project.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteProject(String id) async {
    await _projectDao.softDelete(id);
  }

  Future<model.Project?> getProjectById(String id) async {
    final row = await _projectDao.getById(id);
    if (row == null) return null;
    return model.Project(
      id: row.id,
      workspaceId: row.workspaceId,
      name: row.name,
      description: row.description,
      color: row.color,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
