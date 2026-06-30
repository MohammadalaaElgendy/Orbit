import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/widgets/timeline_indicator.dart';
import '../../../../l10n/app_localizations.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final bool isFirst;
  final bool isLast;
  final bool showTimeline;
  final int? index;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.isFirst = false,
    this.isLast = false,
    this.showTimeline = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    Widget content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Safe way to push footer to bottom
        children: [
          // Top Part: Header, Deadline, Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_rounded, 
                          color: theme.colorScheme.primary, 
                          size: 14,
                        ),
                      ),
                      if (index != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                            ),
                            child: Text(
                              '${index! + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                            fontSize: 15,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (milestone.projectName != null)
                          Text(
                            milestone.projectName!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${(milestone.progress * 100).toInt()}%', 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w900, 
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDeadlineInfo(milestone.dueDate, theme, l10n),
              const SizedBox(height: 8),
              SizedBox(
                height: 34, // Fixed height for 2 lines of description
                child: Text(
                  milestone.description, 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 12,
                  ), 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Bottom Part: Progress Bar and Tasks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: milestone.progress,
                    child: Container(
                      height: 4,
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
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.tasksCount('${milestone.completedTasks}/${milestone.totalTasks}'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (showTimeline) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimelineIndicator(
              isFirst: isFirst,
              isLast: isLast,
              lineColor: milestone.progress >= 1.0 
                  ? Colors.green 
                  : theme.colorScheme.primary,
              nodeSize: 32,
              node: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: (milestone.progress >= 1.0 ? Colors.green : theme.colorScheme.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: milestone.progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Icon(
                  milestone.progress >= 1.0 ? Icons.check_rounded : Icons.flag_rounded,
                  color: milestone.progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                  size: 10,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: content,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/milestone-details', arguments: milestone),
      child: content,
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
