import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/constants/app_constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/task-details', arguments: task),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.xl,
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
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        task.description,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildPriorityBadge(task.priority),
              ],
            ),
            if (task.dueDate != null || task.subtaskCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, thickness: 0.1),
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
                      ),
                    ),
                  ],
                  if (task.dueDate != null && task.subtaskCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
                    ),
                  if (task.subtaskCount > 0) ...[
                    Icon(Icons.account_tree_outlined, size: 12, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedSubtasks}/${task.subtaskCount} Subtasks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
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
                        style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isOverdue(DateTime deadline) => deadline.isBefore(DateTime.now());

  Color _getDeadlineColor(DateTime deadline) {
    if (_isOverdue(deadline)) return Colors.red;
    final diff = deadline.difference(DateTime.now());
    if (diff.inDays < 3) return Colors.orange;
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
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
