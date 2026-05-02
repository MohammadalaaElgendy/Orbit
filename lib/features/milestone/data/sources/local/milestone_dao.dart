import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'milestone_dao.g.dart';

class MilestoneWithTaskCounts {
  final Milestone milestone;
  final int totalTasks;
  final int completedTasks;

  MilestoneWithTaskCounts({
    required this.milestone,
    required this.totalTasks,
    required this.completedTasks,
  });
}

@DriftAccessor(tables: [Milestones, Tasks])
class MilestoneDao extends DatabaseAccessor<AppDatabase> with _$MilestoneDaoMixin {
  MilestoneDao(super.db);

  Future<int> create(MilestonesCompanion milestone) => into(milestones).insert(milestone);

  Future<bool> updateEntry(MilestonesCompanion milestone) => update(milestones).replace(milestone);

  Future<int> softDelete(String id) {
    return (update(milestones)..where((t) => t.id.equals(id))).write(
      MilestonesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Stream<List<Milestone>> watchAll() {
    return (select(milestones)..where((t) => t.deletedAt.isNull())).watch();
  }

  Stream<List<MilestoneWithTaskCounts>> watchByProjectWithCounts(String projectId) {
    final totalTasks = db.tasks.id.count();
    final completedTasks = db.tasks.id.count(filter: db.tasks.status.equals('completed'));

    final query = select(milestones).join([
      leftOuterJoin(
        tasks,
        tasks.milestoneId.equalsExp(milestones.id) & tasks.deletedAt.isNull(),
      ),
    ]);

    query.where(milestones.projectId.equals(projectId) & milestones.deletedAt.isNull());
    query.groupBy([milestones.id]);

    query.addColumns([totalTasks, completedTasks]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return MilestoneWithTaskCounts(
          milestone: row.readTable(milestones),
          totalTasks: row.read(totalTasks) ?? 0,
          completedTasks: row.read(completedTasks) ?? 0,
        );
      }).toList();
    });
  }

  Future<Milestone?> getById(String id) {
    return (select(milestones)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
