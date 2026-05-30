import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/task.dart';
import '../../../../core/constants/app_constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        // نفس ستايل الخلفية والـ Borders بتاعة الـ MilestoneCard
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
      // استخدام InkWell للحصول على الـ Ripple Effect جوة الكارت
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap ?? () => Navigator.pushNamed(context, '/task-details', arguments: task),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIndicator(task.status),
                  const SizedBox(width: AppSpacing.md),
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

  Widget _buildStatusIndicator(TaskStatus status) {
    Color color;
    switch (status) {
      case TaskStatus.todo: color = Colors.grey; break;
      case TaskStatus.inProgress: color = Colors.orange; break;
      case TaskStatus.done: color = Colors.green; break;
    }
    return Container(
      width: 10, // تم تصغيرها قليلاً لتتناسب مع الكارت الـ Clean
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
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
}