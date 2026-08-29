import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/models/task.dart';
import 'package:orbit/shared/models/user.dart';
import 'package:orbit/shared/widgets/glass_card.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:orbit/features/dashboard/presentation/widgets/task_card.dart';
import 'package:orbit/features/dashboard/presentation/view_models/task_view_model.dart';
import 'package:orbit/features/dashboard/presentation/widgets/task_dialog.dart';
import 'package:orbit/features/dashboard/presentation/widgets/task_menu_sheet.dart';
import 'package:orbit/shared/widgets/smart_image.dart';
import 'package:orbit/l10n/app_localizations.dart';

import '../../../../shared/widgets/orbit_avatar.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskMenuSheet(
        task: context.read<TaskViewModel>().currentTask ?? widget.task,
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
            context: context,
            milestoneId: currentTask.milestoneId,
            workspaceId: currentTask.workspaceId, // تمرير معرف مساحة العمل
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

  void _showPriorityPicker(Task currentTask) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((p) => ListTile(
            leading: Icon(Icons.priority_high_rounded, color: _getPriorityColor(p)),
            title: Text(p.getLabel(AppLocalizations.of(context)!)),
            trailing: currentTask.priority == p ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
            onTap: () {
              Navigator.pop(context);
              context.read<TaskViewModel>().updateTask(context, currentTask.copyWith(priority: p));
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showAssigneePicker(Task currentTask, List<User> members) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_off_rounded),
              title: Text(l10n.unassigned),
              trailing: currentTask.assigneeId == null ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(context);
                context.read<TaskViewModel>().updateTask(context, currentTask.copyWith(assigneeId: null));
              },
            ),
            ...members.map((u) => ListTile(
              leading: OrbitAvatar(radius: 14, imageUrl: u.avatarUrl),
              title: Text(u.name),
              trailing: currentTask.assigneeId == u.id ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(context);
                context.read<TaskViewModel>().updateTask(context, currentTask.copyWith(assigneeId: u.id));
              },
            )),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Colors.blue;
      case TaskPriority.medium: return Colors.amber;
      case TaskPriority.high: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<TaskViewModel>();
    final currentTask = viewModel.currentTask ?? widget.task;
    final subtasks = viewModel.subtasks;
    final l10n = AppLocalizations.of(context)!;
    
    // Permission check
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    // Check if user is Admin or Owner
    // We use context.select on DashboardViewModel for the owner check and admin check
    final (isAdminOrOwner, isAssignee) = context.select<DashboardViewModel, (bool, bool)>((dvm) {
       final workspace = dvm.workspaces.where((w) => w.id == currentTask.workspaceId).firstOrNull;
       final isOwner = workspace?.ownerId == currentUserId;
       
       final members = dvm.workspaceMembersMap[currentTask.workspaceId] ?? [];
       final currentMember = members.where((u) => u.id == currentUserId).firstOrNull;
       final isAdmin = currentMember?.role == 'admin' || isOwner;
       
       final isAssignee = currentTask.assigneeId == currentUserId;
       return (isAdmin, isAssignee);
    });

    final canManage = currentTask.assigneeId == null || isAssignee || isAdminOrOwner;

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
          if (canManage)
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: _showTaskMenu,
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _buildBadge(theme, currentTask.status, l10n),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  currentTask.title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildInfoGrid(theme, currentTask, viewModel.workspaceMembers, l10n, canManage),
                const SizedBox(height: AppSpacing.xl),

                if (currentTask.description.trim().isNotEmpty) ...[
                  Text(l10n.description, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    currentTask.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined, size: 24, color: theme.colorScheme.outline),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.noDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.subtasks, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    if (canManage)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        onPressed: _showAddSubtaskDialog,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ]),
            ),
          ),
          if (subtasks.isEmpty)
            SliverToBoxAdapter(child: _buildEmptySubtasks(theme, l10n))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return TaskCard(
                      task: subtasks[index],
                      isSubtask: true,
                      isFirst: index == 0,
                      isLast: index == subtasks.length - 1,
                      showHierarchy: true,
                      onTap: () {
                        Navigator.of(context).pushNamed('/task-details', arguments: subtasks[index]);
                      },
                    );
                  },
                  childCount: subtasks.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, TaskStatus status, AppLocalizations l10n) {
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
        status.getLabel(l10n).toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoGrid(ThemeData theme, Task task, List<User> members, AppLocalizations l10n, bool canManage) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.low: priorityColor = Colors.blue; break;
      case TaskPriority.medium: priorityColor = Colors.amber; break;
      case TaskPriority.high: priorityColor = Colors.red; break;
    }

    final assignee = members.where((u) => u.id == task.assigneeId).firstOrNull;
    final Widget assigneeLeading = (assignee?.avatarUrl != null)
        ? ClipOval(
            child: SmartImage(
              imageUrl: assignee!.avatarUrl!,
              width: 16,
              height: 16,
            ),
          )
        : Icon(Icons.person_outline_rounded, size: 16, color: theme.colorScheme.primary);

    return Column(
      children: [
        Row(
          children: [
            _buildInfoItem(
              theme, 
              l10n.priority, 
              task.priority.getLabel(l10n).toUpperCase(),
              icon: Icons.priority_high_rounded, 
              color: priorityColor,
              onTap: canManage ? () => _showPriorityPicker(task) : null,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildInfoItem(
              theme, 
              l10n.assignee, 
              assignee?.name ?? l10n.unassigned, 
              leading: assigneeLeading,
              onTap: canManage ? () => _showAssigneePicker(task, members) : null,
            ),
          ],
        ),
        if (task.dueDate != null) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoItem(
                theme, 
                l10n.dueDate, 
                DateFormat('MMM dd, yyyy').format(task.dueDate!), 
                icon: Icons.calendar_today_rounded,
                color: task.dueDate!.isBefore(DateTime.now()) && task.status != TaskStatus.done ? Colors.red : null,
              ),
              const SizedBox(width: AppSpacing.md),
              const Spacer(), // Keeps the date card at half width to match the ones above
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value, {Widget? leading, IconData? icon, Color? color, VoidCallback? onTap}) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.lg,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                leading ?? Icon(icon, size: 16, color: color ?? theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      Text(
                        value, 
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                   Icon(Icons.chevron_right_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySubtasks(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.checklist_rounded, size: 40, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.noSubtasks, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
