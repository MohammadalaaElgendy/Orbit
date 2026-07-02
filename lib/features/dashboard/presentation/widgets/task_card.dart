import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:orbit/shared/models/task.dart';
import 'package:orbit/shared/models/user.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/widgets/timeline_indicator.dart';
import 'package:orbit/shared/widgets/orbit_avatar.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'task_menu_sheet.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool isSubtask;
  final bool isFirst;
  final bool isLast;
  final bool showHierarchy;

  const TaskCard({
    super.key, 
    required this.task, 
    this.onTap,
    this.isSubtask = false,
    this.isFirst = false,
    this.isLast = false,
    this.showHierarchy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use context.select to listen specifically to the assignee's data in the member map.
    // This allows the card to rebuild if the task changes (passed via constructor)
    // OR if the assignee's profile data in the workspace member map changes.
    final (assignee, canManage) = context.select<DashboardViewModel, (User?, bool)>((vm) {
      final workspaceMembers = vm.workspaceMembersMap[task.workspaceId] ?? [];
      final assignee = workspaceMembers.where((u) => u.id == task.assigneeId).firstOrNull;
      
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final currentMember = workspaceMembers.where((u) => u.id == currentUserId).firstOrNull;
      
      // Check if user is owner
      final workspace = vm.workspaces.where((w) => w.id == task.workspaceId).firstOrNull;
      final isOwner = workspace?.ownerId == currentUserId;
      
      final isAdmin = currentMember?.role == 'admin' || isOwner;
      final isAssignee = task.assigneeId == currentUserId;
      final canManage = task.assigneeId == null || isAssignee || isAdmin;
      
      return (assignee, canManage);
    });

    Widget card = Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap ?? () => Navigator.pushNamed(context, '/task-details', arguments: task),
        onLongPress: canManage ? () => _showMenu(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Removed redundant status indicator as it's now on the timeline
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (assignee != null)
                    OrbitAvatar(
                      radius: 10,
                      imageUrl: assignee.avatarUrl,
                    ),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(task.priority),
                ],
              ),
              if (task.dueDate != null || task.subtaskCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.05 : 0.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(Icons.access_time_rounded, size: 12, color: _getDeadlineColor(task.dueDate!)),
                      const SizedBox(width: 4),
                      Text(
                        'Due ${DateFormat('MMM dd').format(task.dueDate!)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getDeadlineColor(task.dueDate!),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (task.dueDate != null && task.subtaskCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    if (task.subtaskCount > 0) ...[
                      Icon(
                        Icons.account_tree_outlined,
                        size: 12,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.completedSubtasks}/${task.subtaskCount} Subtasks',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (task.dueDate != null && _isOverdue(task.dueDate!))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (showHierarchy) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSubtask) const SizedBox(width: AppSpacing.lg),
            TimelineIndicator(
              isFirst: isFirst,
              isLast: isLast,
              lineColor: task.status == TaskStatus.done 
                  ? Colors.green 
                  : theme.colorScheme.primary,
              nodeSize: 24,
              node: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: task.status == TaskStatus.done ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: card,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: card,
    );
  }

  // حساب الـ Overdue بناءً على الأيام لتجنب فروق الساعات والدقائق الخفية
  bool _isOverdue(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDay.isBefore(today);
  }

  Color _getDeadlineColor(DateTime deadline) {
    if (_isOverdue(deadline)) return Colors.red;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    final diffInDays = deadlineDay.difference(today).inDays;

    if (diffInDays < 3) return Colors.orange;
    return Colors.green;
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.low: color = Colors.blue; break;
      case TaskPriority.medium: color = Colors.amber; break;
      case TaskPriority.high: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskMenuSheet(task: task),
    );
  }
}