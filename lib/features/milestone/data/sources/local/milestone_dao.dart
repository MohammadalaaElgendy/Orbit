import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';
import 'package:rxdart/rxdart.dart';

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
  Future<int> softDelete(String id) => (delete(milestones)..where((t) => t.id.equals(id))).go();

  Stream<List<MilestoneWithTaskCounts>> watchAllWithCounts() {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])..orderBy([OrderingTerm(expression: milestones.createdAt, mode: OrderingMode.asc)]))
    .watch()
    .switchMap((rows) {
      if (rows.isEmpty) return Stream.value([]);
      
      final milestoneIds = rows.map((r) => r.readTable(milestones).id).toList();
      
      // Watch tasks for all these milestones
      return (select(tasks)..where((t) => t.milestoneId.isIn(milestoneIds)))
        .watch()
        .map((allTasks) {
          return rows.map((row) {
            final m = row.readTable(milestones);
            final p = row.readTableOrNull(projects);
            final w = row.readTableOrNull(workspaces);
            
            final milestoneTasks = allTasks.where((t) => t.milestoneId == m.id);
            final doneCount = milestoneTasks.where((t) => t.status == 'done').length;

            return MilestoneWithTaskCounts(
              milestone: m,
              projectName: p?.name,
              workspaceName: w?.name,
              totalTasks: milestoneTasks.length,
              completedTasks: doneCount,
            );
          }).toList();
        });
    });
  }

  Stream<List<MilestoneWithTaskCounts>> watchByProjectWithCounts(String projectId) {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])
      ..where(milestones.projectId.equals(projectId))
      ..orderBy([OrderingTerm(expression: milestones.createdAt, mode: OrderingMode.asc)]))
    .watch()
    .switchMap((rows) {
      if (rows.isEmpty) return Stream.value([]);
      
      final milestoneIds = rows.map((r) => r.readTable(milestones).id).toList();
      
      return (select(tasks)..where((t) => t.milestoneId.isIn(milestoneIds)))
        .watch()
        .map((allTasks) {
          return rows.map((row) {
            final m = row.readTable(milestones);
            final p = row.readTableOrNull(projects);
            final w = row.readTableOrNull(workspaces);
            
            final milestoneTasks = allTasks.where((t) => t.milestoneId == m.id);
            final doneCount = milestoneTasks.where((t) => t.status == 'done').length;

            return MilestoneWithTaskCounts(
              milestone: m,
              projectName: p?.name,
              workspaceName: w?.name,
              totalTasks: milestoneTasks.length,
              completedTasks: doneCount,
            );
          }).toList();
        });
    });
  }

  Stream<MilestoneWithTaskCounts?> watchByIdWithCounts(String id) {
    final milestoneStream = (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])..where(milestones.id.equals(id))).watchSingleOrNull();

    final taskStream = (select(tasks)..where((t) => t.milestoneId.equals(id))).watch();

    return Rx.combineLatest2(milestoneStream, taskStream, (row, allTasks) {
      if (row == null) return null;
      final m = row.readTable(milestones);
      final p = row.readTableOrNull(projects);
      final w = row.readTableOrNull(workspaces);
      final doneCount = allTasks.where((t) => t.status == 'done').length;
      return MilestoneWithTaskCounts(
        milestone: m,
        projectName: p?.name,
        workspaceName: w?.name,
        totalTasks: allTasks.length,
        completedTasks: doneCount,
      );
    });
  }

  Future<Milestone?> getById(String id) => (select(milestones)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> softDeleteByWorkspace(String workspaceId) {
    return (delete(milestones)..where((t) => t.workspaceId.equals(workspaceId))).go();
  }

  Stream<List<MilestoneWithTaskCounts>> watchByWorkspaceWithCounts(String workspaceId) {
    return (select(milestones).join([
      leftOuterJoin(projects, projects.id.equalsExp(milestones.projectId)),
      leftOuterJoin(workspaces, workspaces.id.equalsExp(projects.workspaceId)),
    ])
      ..where(milestones.workspaceId.equals(workspaceId))
      ..orderBy([OrderingTerm(expression: milestones.createdAt, mode: OrderingMode.asc)]))
    .watch()
    .switchMap((rows) {
      if (rows.isEmpty) return Stream.value([]);
      
      final milestoneIds = rows.map((r) => r.readTable(milestones).id).toList();
      
      return (select(tasks)..where((t) => t.milestoneId.isIn(milestoneIds)))
        .watch()
        .map((allTasks) {
          return rows.map((row) {
            final m = row.readTable(milestones);
            final p = row.readTableOrNull(projects);
            final w = row.readTableOrNull(workspaces);
            
            final milestoneTasks = allTasks.where((t) => t.milestoneId == m.id);
            final doneCount = milestoneTasks.where((t) => t.status == 'done').length;

            return MilestoneWithTaskCounts(
              milestone: m,
              projectName: p?.name,
              workspaceName: w?.name,
              totalTasks: milestoneTasks.length,
              completedTasks: doneCount,
            );
          }).toList();
        });
    });
  }
}
