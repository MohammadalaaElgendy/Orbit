import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../widgets/task_card.dart';
import '../view_models/task_view_model.dart';
import '../widgets/task_dialog.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTaskDetails(widget.task);
    });
  }

  void _showTaskMenu() {
    final viewModel = context.read<TaskViewModel>();
    final currentTask = viewModel.currentTask ?? widget.task;
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Task'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => TaskDialog(
                  task: currentTask,
                  workspaceMembers: viewModel.workspaceMembers,
                  onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
                    viewModel.updateTask(Task(
                      id: currentTask.id,
                      milestoneId: currentTask.milestoneId,
                      parentTaskId: currentTask.parentTaskId,
                      title: title,
                      description: description,
                      status: status,
                      priority: priority,
                      assigneeId: assigneeId,
                      dueDate: dueDate,
                      createdAt: currentTask.createdAt,
                      updatedAt: DateTime.now(),
                    ));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              viewModel.deleteTask(currentTask.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog() {
    final viewModel = context.read<TaskViewModel>();
    final currentTask = viewModel.currentTask ?? widget.task;
    showDialog(
      context: context,
      builder: (_) => TaskDialog(
        milestoneId: currentTask.milestoneId,
        parentTaskId: currentTask.id,
        workspaceMembers: viewModel.workspaceMembers,
        onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
          viewModel.createTask(
            milestoneId: currentTask.milestoneId,
            parentTaskId: currentTask.id,
            title: title,
            description: description,
            status: status,
            priority: priority,
            assigneeId: assigneeId,
            dueDate: dueDate,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<TaskViewModel>();
    final currentTask = viewModel.currentTask ?? widget.task;
    final subtasks = viewModel.subtasks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.lg,
            blur: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () {
                // Ensure we pop the current screen
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: _showTaskMenu,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge(theme, currentTask.status),
            const SizedBox(height: AppSpacing.md),
            Text(
              currentTask.title,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoGrid(theme, currentTask, viewModel.workspaceMembers),
            const SizedBox(height: AppSpacing.xl),
            Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              currentTask.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtasks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  onPressed: _showAddSubtaskDialog,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (subtasks.isEmpty)
              _buildEmptySubtasks(theme)
            else
              ...subtasks.map((st) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TaskCard(
                  task: st,
                  onTap: () {
                    // USE EXPLICIT PUSH TO ENSURE DISTINCT BACK-STACK ENTRY
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: st),
                      ),
                    );
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, TaskStatus status) {
    Color color;
    switch (status) {
      case TaskStatus.todo: color = Colors.grey; break;
      case TaskStatus.inProgress: color = Colors.orange; break;
      case TaskStatus.done: color = Colors.green; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoGrid(ThemeData theme, Task task, List<User> members) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.low: priorityColor = Colors.blue; break;
      case TaskPriority.medium: priorityColor = Colors.amber; break;
      case TaskPriority.high: priorityColor = Colors.red; break;
    }

    final assignee = members.where((u) => u.id == task.assigneeId).firstOrNull;

    return Row(
      children: [
        _buildInfoItem(theme, 'Priority', task.priority.name.toUpperCase(), Icons.priority_high_rounded, color: priorityColor),
        const SizedBox(width: AppSpacing.md),
        _buildInfoItem(theme, 'Assignee', assignee?.name ?? 'Unassigned', Icons.person_outline_rounded),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubtasks(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.checklist_rounded, size: 40, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.sm),
            Text('No subtasks yet', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
