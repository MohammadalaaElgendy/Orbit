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

    // 1. Create Mock Users
    final users = [
      model.User(id: uuid.v4(), name: 'John Doe', email: 'john@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=1'),
      model.User(id: uuid.v4(), name: 'Jane Smith', email: 'jane@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=2'),
      model.User(id: uuid.v4(), name: 'Alex Rivera', email: 'alex@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=3'),
    ];

    for (var user in users) {
      await userRepo.createUser(user);
    }

    // 2. Create Workspace
    final wsId = uuid.v4();
    await workspaceRepo.createWorkspace(model.Workspace(
      id: wsId,
      name: 'Orbit Development',
      description: 'Main workspace for Orbit project tracking.',
      imageUrl: 'assets/images/workspaces/ws_1.webp',
      createdAt: now,
      updatedAt: now,
    ));

    // Add members to workspace
    for (var user in users) {
      await workspaceRepo.addMemberToWorkspace(wsId, user.id, 'member');
    }

    // 3. Create Project
    final projectId = uuid.v4();
    await projectRepo.createProject(model.Project(
      id: projectId,
      workspaceId: wsId,
      name: 'Mobile App',
      description: 'Flutter cross-platform application.',
      color: '#6366F1',
      createdAt: now,
      updatedAt: now,
    ));

    // 4. Create Milestone
    final milestoneId = uuid.v4();
    await milestoneRepo.createMilestone(model.Milestone(
      id: milestoneId,
      projectId: projectId,
      name: 'Phase 2: Full CRUD',
      description: 'Implementing full CRUD functionality and workspace members.',
      dueDate: now.add(const Duration(days: 14)),
      createdAt: now,
      updatedAt: now,
    ));

    // 5. Create Root Task
    final taskId = uuid.v4();
    await taskRepo.createTask(model.Task(
      id: taskId,
      milestoneId: milestoneId,
      title: 'Database & Repository Updates',
      description: 'Update Drift schema and implement repository methods.',
      assigneeId: users[0].id,
      status: model.TaskStatus.inProgress,
      priority: model.TaskPriority.high,
      createdAt: now,
      updatedAt: now,
    ));

    // 6. Create Subtasks
    await taskRepo.createTask(model.Task(
      id: uuid.v4(),
      milestoneId: milestoneId,
      parentTaskId: taskId,
      title: 'Add SeedControl Table',
      description: 'Create a dedicated table for seed management.',
      status: model.TaskStatus.done,
      priority: model.TaskPriority.medium,
      createdAt: now,
      updatedAt: now,
    ));

    await taskRepo.createTask(model.Task(
      id: uuid.v4(),
      milestoneId: milestoneId,
      parentTaskId: taskId,
      title: 'Update Repositories',
      description: 'Add CRUD and member management methods.',
      status: model.TaskStatus.inProgress,
      priority: model.TaskPriority.medium,
      createdAt: now,
      updatedAt: now,
    ));

    // Add another workspace
    await workspaceRepo.createWorkspace(model.Workspace(
      id: uuid.v4(),
      name: 'Marketing',
      description: 'Growth strategies and global campaigns.',
      imageUrl: 'assets/images/workspaces/ws_2.webp',
      createdAt: now,
      updatedAt: now,
    ));

    await database.markAsSeeded();
  }
}
