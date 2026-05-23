import 'package:uuid/uuid.dart';
import '../../../shared/models/workspace.dart' as model;
import '../../../shared/models/project.dart' as model;
import '../../../shared/models/milestone.dart' as model;
import '../../../shared/models/task.dart' as model;
import '../../../shared/models/user.dart' as model;
import '../../../features/auth/domain/repositories/user_repository.dart';
import '../../../features/workspace/domain/repositories/workspace_repository.dart';
import '../../../features/workspace/domain/repositories/project_repository.dart';
import '../../../features/milestone/domain/repositories/milestone_repository.dart';
import '../../../features/dashboard/domain/repositories/task_repository.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static Future<void> seed(
    AppDatabase database,
    UserRepository userRepo,
    WorkspaceRepository workspaceRepo,
    ProjectRepository projectRepo,
    MilestoneRepository milestoneRepo,
    TaskRepository taskRepo,
  ) async {
    // 0. Auto-fix legacy .jpg paths for existing users
    await database.customStatement(
      "UPDATE workspaces SET image_url = REPLACE(image_url, '.jpg', '.webp') WHERE image_url LIKE '%.jpg'"
    );

    final alreadySeeded = await database.isDatabaseSeeded();
    if (alreadySeeded) return;

    final uuid = const Uuid();
    final now = DateTime.now();

    // 1. Create a Mock User (Necessary for relations)
    final userId = uuid.v4();
    final mockUser = model.User(
      id: userId,
      name: 'Orbit Dev',
      email: 'dev@orbit.com',
      avatarUrl: 'https://i.pravatar.cc/150?u=$userId',
      isVerified: true,
    );
    await userRepo.createUser(mockUser);

    // 2. Create Workspace
    final wsId = uuid.v4();
    await workspaceRepo.createWorkspace(model.Workspace(
      id: wsId,
      name: 'Orbit Development',
      description: 'Main workspace for Orbit project tracking.',
      imageUrl: 'assets/images/workspaces/ws_1.webp',
      ownerId: userId,
      createdBy: userId,
      createdAt: now,
      updatedAt: now,
    ));

    // 3. Create Project
    final projectId = uuid.v4();
    final project = model.Project(
      id: projectId,
      workspaceId: wsId,
      name: 'Mobile App',
      description: 'Flutter cross-platform application.',
      color: '#6366F1',
      createdAt: now,
      updatedAt: now,
    );
    await projectRepo.createProject(project);

    // 4. Create Milestone
    final milestoneId = uuid.v4();
    await milestoneRepo.createMilestone(model.Milestone(
      id: milestoneId,
      workspaceId: wsId,
      projectId: projectId,
      name: 'Phase 2: Full CRUD',
      description: 'Implementing full CRUD functionality and workspace members.',
      dueDate: now.add(const Duration(days: 14)),
      createdAt: now,
      updatedAt: now,
    ), wsId);

    // 5. Create Root Task
    final taskId = uuid.v4();
    await taskRepo.createTask(model.Task(
      id: taskId,
      workspaceId: wsId,
      milestoneId: milestoneId,
      title: 'Database & Repository Updates',
      description: 'Update Drift schema and implement repository methods.',
      assigneeId: userId,
      createdBy: userId,
      status: model.TaskStatus.inProgress,
      priority: model.TaskPriority.high,
      createdAt: now,
      updatedAt: now,
    ), wsId);

    // 6. Create Subtasks
    await taskRepo.createTask(model.Task(
      id: uuid.v4(),
      workspaceId: wsId,
      milestoneId: milestoneId,
      parentTaskId: taskId,
      title: 'Add SeedControl Table',
      description: 'Create a dedicated table for seed management.',
      createdBy: userId,
      status: model.TaskStatus.done,
      priority: model.TaskPriority.medium,
      createdAt: now,
      updatedAt: now,
    ), wsId);

    await taskRepo.createTask(model.Task(
      id: uuid.v4(),
      workspaceId: wsId,
      milestoneId: milestoneId,
      parentTaskId: taskId,
      title: 'Update Repositories',
      description: 'Add CRUD and member management methods.',
      createdBy: userId,
      status: model.TaskStatus.inProgress,
      priority: model.TaskPriority.medium,
      createdAt: now,
      updatedAt: now,
    ), wsId);

    // Add another workspace
    await workspaceRepo.createWorkspace(model.Workspace(
      id: uuid.v4(),
      name: 'Marketing',
      description: 'Growth strategies and global campaigns.',
      imageUrl: 'assets/images/workspaces/ws_2.webp',
      ownerId: userId,
      createdBy: userId,
      createdAt: now,
      updatedAt: now,
    ));

    await database.markAsSeeded();
  }
}
