import '../../../../shared/models/milestone.dart' as model;
import '../../data/sources/local/milestone_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class MilestoneRepository {
  final MilestoneDao _milestoneDao;

  MilestoneRepository(this._milestoneDao);

  Future<void> createMilestone(model.Milestone milestone) async {
    await _milestoneDao.create(db.MilestonesCompanion(
      id: Value(milestone.id),
      projectId: Value(milestone.projectId),
      name: Value(milestone.name),
      description: Value(milestone.description),
      dueDate: Value(milestone.dueDate),
      createdAt: Value(milestone.createdAt),
      updatedAt: Value(milestone.updatedAt),
    ));
  }

  Stream<List<model.Milestone>> watchAllMilestones() {
    return _milestoneDao.watchAllWithCounts().map((rows) => rows
        .map(_mapWithCountsToDomain)
        .toList());
  }

  Stream<List<model.Milestone>> watchMilestonesByProject(String projectId) {
    return _milestoneDao.watchByProjectWithCounts(projectId).map((rows) => rows
        .map(_mapWithCountsToDomain)
        .toList());
  }

  Stream<model.Milestone?> watchMilestoneById(String id) {
    return _milestoneDao.watchByIdWithCounts(id).map((row) {
      if (row == null) return null;
      return _mapWithCountsToDomain(row);
    });
  }

  model.Milestone _mapWithCountsToDomain(MilestoneWithTaskCounts row) {
    return model.Milestone(
      id: row.milestone.id,
      projectId: row.milestone.projectId,
      projectName: row.projectName,
      workspaceName: row.workspaceName,
      name: row.milestone.name,
      description: row.milestone.description,
      dueDate: row.milestone.dueDate,
      createdAt: row.milestone.createdAt,
      updatedAt: row.milestone.updatedAt,
      totalTasks: row.totalTasks,
      completedTasks: row.completedTasks,
      progress: row.totalTasks > 0 ? row.completedTasks / row.totalTasks : 0.0,
    );
  }

  Future<void> updateMilestone(model.Milestone milestone) async {
    await _milestoneDao.updateEntry(db.MilestonesCompanion(
      id: Value(milestone.id),
      projectId: Value(milestone.projectId),
      name: Value(milestone.name),
      description: Value(milestone.description),
      dueDate: Value(milestone.dueDate),
      createdAt: Value(milestone.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteMilestone(String id) async {
    await _milestoneDao.softDelete(id);
  }

  Future<model.Milestone?> getMilestoneById(String id) async {
    final row = await _milestoneDao.getById(id);
    if (row == null) return null;
    return model.Milestone(
      id: row.id,
      projectId: row.projectId,
      name: row.name,
      description: row.description,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
