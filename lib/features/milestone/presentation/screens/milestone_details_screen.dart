import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart' as model;
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../dashboard/presentation/widgets/task_card.dart';
import '../view_models/milestone_view_model.dart';
import '../widgets/milestone_menu_sheet.dart';
import '../../../dashboard/presentation/widgets/task_dialog.dart';
import '../../../dashboard/presentation/view_models/task_view_model.dart';
import '../../../../l10n/app_localizations.dart';

import 'package:intl/intl.dart';

enum TaskStatusFilter { all, pending, completed }

class MilestoneDetailsScreen extends StatefulWidget {
  final model.Milestone milestone;

  const MilestoneDetailsScreen({super.key, required this.milestone});

  @override
  State<MilestoneDetailsScreen> createState() => _MilestoneDetailsScreenState();
}

class _MilestoneDetailsScreenState extends State<MilestoneDetailsScreen> {
  TaskStatusFilter _filter = TaskStatusFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilestoneViewModel>().loadMilestoneData(widget.milestone.id);
    });
  }

  void _showMilestoneMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MilestoneMenuSheet(
        milestone: context.read<MilestoneViewModel>().currentMilestone ?? widget.milestone,
      ),
    );
  }

  void _showAddTaskDialog() {
    final viewModel = context.read<MilestoneViewModel>();
    final currentMilestone = viewModel.currentMilestone ?? widget.milestone;
    
    showDialog(
      context: context,
      builder: (_) => TaskDialog(
        milestoneId: currentMilestone.id,
        workspaceMembers: viewModel.workspaceMembers,
        onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
          context.read<TaskViewModel>().createTask(
            context: context,
            milestoneId: currentMilestone.id,
            workspaceId: currentMilestone.workspaceId,
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
    final viewModel = context.watch<MilestoneViewModel>();
    final currentMilestone = viewModel.currentMilestone ?? widget.milestone;
    final rawTasks = viewModel.tasks;
    final l10n = AppLocalizations.of(context)!;

    // Categorize tasks
    final pendingTasks = rawTasks.where((t) => t.status != TaskStatus.done).toList();
    final completedTasks = rawTasks.where((t) => t.status == TaskStatus.done).toList();

    // Sort pending tasks: High priority first, then due date / creation date
    pendingTasks.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    // Sort completed tasks by updatedAt / createdAt descending
    completedTasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Filtered list based on tab
    List<Task> displayedTasks;
    switch (_filter) {
      case TaskStatusFilter.all:
        displayedTasks = [...pendingTasks, ...completedTasks];
        break;
      case TaskStatusFilter.pending:
        displayedTasks = pendingTasks;
        break;
      case TaskStatusFilter.completed:
        displayedTasks = completedTasks;
        break;
    }

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => Navigator.pop(context),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.lg,
              blur: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: _showMilestoneMenu,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Icon(Icons.more_vert_rounded, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                Center(
                  child: Hero(
                    tag: 'milestone_icon_${currentMilestone.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.flag_rounded, color: theme.colorScheme.primary, size: 32),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  currentMilestone.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                if (currentMilestone.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    currentMilestone.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _buildStatsRow(theme, currentMilestone, l10n),
                const SizedBox(height: AppSpacing.xl),
                
                // Tasks Header and Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.tasks, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    TextButton.icon(
                      onPressed: _showAddTaskDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.addTask),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Task Filter Segmented Control
                if (rawTasks.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: '${l10n.total} (${rawTasks.length})',
                          filter: TaskStatusFilter.all,
                          theme: theme,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip(
                          label: '${l10n.statusInProgress} (${pendingTasks.length})',
                          filter: TaskStatusFilter.pending,
                          theme: theme,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip(
                          label: '${l10n.statusDone} (${completedTasks.length})',
                          filter: TaskStatusFilter.completed,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),

                if (displayedTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        rawTasks.isEmpty ? l10n.noTasksForMilestone : l10n.noTasksFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...displayedTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return TaskCard(
                      task: task,
                      isFirst: index == 0,
                      isLast: index == displayedTasks.length - 1,
                      showHierarchy: true,
                    );
                  }),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TaskStatusFilter filter,
    required ThemeData theme,
  }) {
    final isSelected = _filter == filter;
    final accentColor = theme.brightness == Brightness.light 
        ? theme.colorScheme.primary 
        : theme.colorScheme.primaryContainer;

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: accentColor,
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isSelected
              ? accentColor
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatsRow(ThemeData theme, model.Milestone milestone, AppLocalizations l10n) {
    return Column(
      children: [
        _buildStatItem(
          theme, 
          l10n.deadline, 
          milestone.dueDate != null ? DateFormat('MMMM dd, yyyy').format(milestone.dueDate!) : l10n.noDeadline, 
          Icons.calendar_today_rounded,
          subtitle: _getDeadlineSubtitle(milestone.dueDate, l10n, milestone.progress),
          subtitleColor: _getDeadlineColor(milestone.dueDate, milestone.progress),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                theme, 
                l10n.progressLabel, 
                '${(milestone.progress * 100).toInt()}%', 
                Icons.donut_large_rounded
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatItem(
                theme, 
                l10n.tasks, 
                '${milestone.completedTasks}/${milestone.totalTasks}',
                Icons.check_circle_outline_rounded
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _getDeadlineSubtitle(DateTime? deadline, AppLocalizations l10n, double progress) {
    if (progress >= 1.0) return l10n.statusDone;
    if (deadline == null) return null;
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return l10n.overdue;
    if (diff.inDays == 0) return l10n.hoursRemaining(diff.inHours);
    return l10n.daysRemaining(diff.inDays);
  }

  Color? _getDeadlineColor(DateTime? deadline, double progress) {
    if (progress >= 1.0) return Colors.green;
    if (deadline == null) return null;
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return Colors.red;
    if (diff.inDays < 3) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, {String? subtitle, Color? subtitleColor}) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.xl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: subtitleColor ?? theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
