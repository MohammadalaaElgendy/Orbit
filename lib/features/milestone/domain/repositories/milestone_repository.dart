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

  Stream<List<model.Milestone>> watchMilestonesByProject(String projectId) {
    return _milestoneDao.watchByProject(projectId).map((rows) => rows
        .map((row) => model.Milestone(
              id: row.id,
              projectId: row.projectId,
              name: row.name,
              description: row.description,
              dueDate: row.dueDate,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ))
        .toList());
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
