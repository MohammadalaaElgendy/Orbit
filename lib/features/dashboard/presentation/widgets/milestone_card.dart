import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../l10n/app_localizations.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const MilestoneCard({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/milestone-details', arguments: milestone),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_rounded, 
                    color: theme.colorScheme.primary, 
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.name, 
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (milestone.projectName != null)
                        Text(
                          milestone.projectName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${(milestone.progress * 100).toInt()}%', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w900, 
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDeadlineInfo(milestone.dueDate, theme, l10n),
            const SizedBox(height: 12),
            Text(
              milestone.description, 
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13,
              ), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: milestone.progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tasksCount('${milestone.completedTasks}/${milestone.totalTasks}'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineInfo(DateTime? deadline, ThemeData theme, AppLocalizations l10n) {
    if (deadline == null) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final difference = deadline.difference(now);
    final isOverdue = difference.isNegative;
    final isUrgent = !isOverdue && difference.inDays < 3;
    
    final color = isOverdue ? Colors.red : (isUrgent ? Colors.orange : Colors.green);
    final icon = isOverdue ? Icons.error_outline_rounded : Icons.access_time_rounded;
    
    String text;
    if (isOverdue) {
      text = l10n.overdue;
    } else if (difference.inDays > 0) {
      text = l10n.daysLeft(difference.inDays);
    } else if (difference.inHours > 0) {
      text = l10n.hoursLeft(difference.inHours);
    } else {
      text = l10n.dueSoon;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('MMM dd').format(deadline),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
