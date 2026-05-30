import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart' as model;
import '../../../../shared/widgets/glass_card.dart';
import '../../../dashboard/presentation/widgets/task_card.dart';
import '../view_models/milestone_view_model.dart';
import '../widgets/milestone_menu_sheet.dart';
import '../../../dashboard/presentation/widgets/task_dialog.dart';
import '../../../dashboard/presentation/view_models/task_view_model.dart';
import '../../../../l10n/app_localizations.dart';

import 'package:intl/intl.dart';

class MilestoneDetailsScreen extends StatefulWidget {
  final model.Milestone milestone;

  const MilestoneDetailsScreen({super.key, required this.milestone});

  @override
  State<MilestoneDetailsScreen> createState() => _MilestoneDetailsScreenState();
}

class _MilestoneDetailsScreenState extends State<MilestoneDetailsScreen> {
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
      builder: (_) => MilestoneMenuSheet(
        milestone: context.read<MilestoneViewModel>().currentMilestone ?? widget.milestone,
      ),
    );
  }

  void _showAddTaskDialog() {
    final viewModel = context.read<MilestoneViewModel>();
    showDialog(
      context: context,
      builder: (_) => TaskDialog(
        milestoneId: widget.milestone.id,
        workspaceMembers: viewModel.workspaceMembers,
        onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
          context.read<TaskViewModel>().createTask(
            context: context,
            milestoneId: widget.milestone.id,
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
    final tasks = viewModel.tasks;
    final l10n = AppLocalizations.of(context)!;

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
            enabled: false,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: _showMilestoneMenu,
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  currentMilestone.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildStatsRow(theme, currentMilestone, l10n),
                const SizedBox(height: AppSpacing.xl),
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
                const SizedBox(height: AppSpacing.md),
                if (tasks.isEmpty)
                   Center(child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: Text(l10n.noTasksForMilestone),
                   ))
                else
                  ...tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: TaskCard(task: task),
                  )),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
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
          subtitle: _getDeadlineSubtitle(milestone.dueDate, l10n),
          subtitleColor: _getDeadlineColor(milestone.dueDate),
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

  String? _getDeadlineSubtitle(DateTime? deadline, AppLocalizations l10n) {
    if (deadline == null) return null;
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return l10n.overdue;
    if (diff.inDays == 0) return l10n.hoursRemaining(diff.inHours);
    return l10n.daysRemaining(diff.inDays);
  }

  Color? _getDeadlineColor(DateTime? deadline) {
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
      enabled: false,
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
