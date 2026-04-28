import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/glass_card.dart';

class MilestoneDetailsScreen extends StatelessWidget {
  final Milestone milestone;

  const MilestoneDetailsScreen({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Data for Recursive Subtasks
    final tasks = [
      Task(
        id: 't1',
        milestoneId: milestone.id,
        title: 'Design System Implementation',
        description: 'Complete all UI components based on the new glassmorphic design language.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        subtasks: [
          Task(id: 'st1', milestoneId: milestone.id, title: 'Refactor GlassCard', description: 'Remove grain and optimize blur performance.'),
          Task(id: 'st2', milestoneId: milestone.id, title: 'Typography Mapping', description: 'Ensure Manrope and Inter are applied globally.'),
        ],
      ),
      Task(
        id: 't2',
        milestoneId: milestone.id,
        title: 'Workflow Orchestration',
        description: 'Establish the core project hierarchy logic and state management flows.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        subtasks: [
          Task(
            id: 'st3', 
            milestoneId: milestone.id, 
            title: 'Recursive Subtasks', 
            description: 'Implement a clean tree view for unlimited subtask nesting.',
            subtasks: [
              Task(id: 'sst1', milestoneId: milestone.id, title: 'Depth Indentation', description: 'Visual clarity for nested levels.'),
            ],
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.8),
            radius: 1.2,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.03),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Milestone Details', 
                    style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.md),
                    _buildMilestoneHeader(theme),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Task Hierarchy', style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...tasks.map((task) => _TaskItem(task: task)),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneHeader(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.xxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(milestone.name, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('Active Phase', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            milestone.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('${(milestone.progress * 100).toInt()}%', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: milestone.progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${milestone.completedTasks} of ${milestone.totalTasks} tasks completed',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatefulWidget {
  final Task task;
  final int depth;

  const _TaskItem({required this.task, this.depth = 0});

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> {
  bool _isExpanded = true; // Default expanded for better visibility in mock

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubtasks = widget.task.subtasks.isNotEmpty;
    final isDone = widget.task.status == TaskStatus.done;

    return Column(
      children: [
        GestureDetector(
          onTap: hasSubtasks ? () => setState(() => _isExpanded = !_isExpanded) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(
              left: widget.depth * 20.0 + AppSpacing.sm,
              right: AppSpacing.sm,
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: widget.depth == 0 ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: widget.depth == 0 ? BorderRadius.circular(AppRadius.lg) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasSubtasks)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  const SizedBox(width: 26),
                
                GestureDetector(
                  onTap: () {}, // Toggle completion logic later
                  child: Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: isDone ? Colors.green : theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: widget.depth == 0 ? FontWeight.w800 : FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : null,
                        ),
                      ),
                      if (widget.task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.task.description,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.depth == 0)
                  _buildPriorityBadge(theme, widget.task.priority),
              ],
            ),
          ),
        ),
        if (_isExpanded && hasSubtasks)
          ...widget.task.subtasks.map((st) => _TaskItem(task: st, depth: widget.depth + 1)),
        if (widget.depth == 0) const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildPriorityBadge(ThemeData theme, TaskPriority priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return Colors.redAccent;
      case TaskPriority.medium: return Colors.orangeAccent;
      case TaskPriority.low: return Colors.blueAccent;
    }
  }
}
