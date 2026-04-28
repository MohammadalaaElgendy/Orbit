import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // Navigate to task details (using a placeholder route or logic for now)
        Navigator.pushNamed(context, '/task-details', arguments: task);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.08) 
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  task.priority == TaskPriority.high ? Colors.redAccent : theme.colorScheme.primary,
                  (task.priority == TaskPriority.high ? Colors.redAccent : theme.colorScheme.primary).withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                if (task.priority == TaskPriority.high)
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title, 
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.description, 
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded, 
              color: theme.colorScheme.primary.withValues(alpha: 0.5), 
              size: 20,
            ),
          ),
        ],
      ),
    ));
  }
}
