import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'milestone_dao.g.dart';

@DriftAccessor(tables: [Milestones])
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

  Stream<List<Milestone>> watchByProject(String projectId) {
    return (select(milestones)
          ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<Milestone?> getById(String id) {
    return (select(milestones)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
