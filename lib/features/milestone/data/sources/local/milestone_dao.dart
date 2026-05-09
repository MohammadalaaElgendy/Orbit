import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'milestone_dao.g.dart';

class MilestoneWithTaskCounts {
  final Milestone milestone;
  final String? projectName;
  final String? workspaceName;
  final int totalTasks;
  final int completedTasks;

  MilestoneWithTaskCounts({
    required this.milestone,
    this.projectName,
    this.workspaceName,
    required this.totalTasks,
    required this.completedTasks,
  });
}

@DriftAccessor(tables: [Milestones, Tasks, Projects, Workspaces])
class MilestoneDao extends DatabaseAccessor<AppDatabase> with _$MilestoneDaoMixin {
  MilestoneDao(super.db);

  Future<int> create(MilestonesCompanion milestone) => into(milestones).insert(milestone);
  Future<bool> updateEntry(MilestonesCompanion milestone) => update(milestones).replace(milestone);
  Future<int> softDelete(String id) => (update(milestones)..where((t) => t.id.equals(id))).write(MilestonesCompanion(deletedAt: Value(DateTime.now())));

  Stream<List<MilestoneWithTaskCounts>> watchAllWithCounts() {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])..where(milestones.deletedAt.isNull())).watch().asyncMap((rows) async {
      final List<MilestoneWithTaskCounts> results = [];
      for (final row in rows) {
        final m = row.readTable(milestones);
        final p = row.readTableOrNull(projects);
        final w = row.readTableOrNull(workspaces);

        // Fetch counts reactively. Drift will re-emit if tasks change because we are inside the database accessor.
        final allTasks = await (select(tasks)..where((t) => t.milestoneId.equals(m.id) & t.deletedAt.isNull())).get();
        final doneCount = allTasks.where((t) => t.status == 'done').length;

        results.add(MilestoneWithTaskCounts(
          milestone: m,
          projectName: p?.name,
          workspaceName: w?.name,
          totalTasks: allTasks.length,
          completedTasks: doneCount,
        ));
      }
      return results;
    });
  }

  // Same logic for filtered queries
  Stream<List<MilestoneWithTaskCounts>> watchByProjectWithCounts(String projectId) {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])..where(milestones.projectId.equals(projectId) & milestones.deletedAt.isNull())).watch().asyncMap((rows) async {
      final List<MilestoneWithTaskCounts> results = [];
      for (final row in rows) {
        final m = row.readTable(milestones);
        final p = row.readTableOrNull(projects);
        final w = row.readTableOrNull(workspaces);
        final allTasks = await (select(tasks)..where((t) => t.milestoneId.equals(m.id) & t.deletedAt.isNull())).get();
        results.add(MilestoneWithTaskCounts(
          milestone: m,
          projectName: p?.name,
          workspaceName: w?.name,
          totalTasks: allTasks.length,
          completedTasks: allTasks.where((t) => t.status == 'done').length,
        ));
      }
      return results;
    });
  }

  Stream<MilestoneWithTaskCounts?> watchByIdWithCounts(String id) {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])..where(milestones.id.equals(id) & milestones.deletedAt.isNull())).watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final m = row.readTable(milestones);
      final p = row.readTableOrNull(projects);
      final w = row.readTableOrNull(workspaces);
      final allTasks = await (select(tasks)..where((t) => t.milestoneId.equals(m.id) & t.deletedAt.isNull())).get();
      return MilestoneWithTaskCounts(
        milestone: m,
        projectName: p?.name,
        workspaceName: w?.name,
        totalTasks: allTasks.length,
        completedTasks: allTasks.where((t) => t.status == 'done').length,
      );
    });
  }

  Future<Milestone?> getById(String id) => (select(milestones)..where((t) => t.id.equals(id))).getSingleOrNull();
}
