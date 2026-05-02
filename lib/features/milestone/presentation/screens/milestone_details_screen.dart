import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart' as model;
import '../../../../shared/widgets/glass_card.dart';
import '../../../dashboard/presentation/widgets/task_card.dart';
import '../view_models/milestone_view_model.dart';

import '../widgets/milestone_dialog.dart';
import '../../../dashboard/presentation/widgets/task_dialog.dart';
import '../../../dashboard/presentation/view_models/task_view_model.dart';

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
    final viewModel = context.read<MilestoneViewModel>();
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Milestone'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => MilestoneDialog(
                  milestone: widget.milestone,
                  onSave: (name, desc, dueDate) {
                    viewModel.updateMilestone(model.Milestone(
                      id: widget.milestone.id,
                      projectId: widget.milestone.projectId,
                      name: name,
                      description: desc,
                      dueDate: dueDate,
                      createdAt: widget.milestone.createdAt,
                      updatedAt: DateTime.now(),
                    ));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Milestone', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              viewModel.deleteMilestone(widget.milestone.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
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
    final tasks = viewModel.tasks;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              Colors.transparent,
              theme.colorScheme.secondary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: _showMilestoneMenu,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'milestone_${widget.milestone.id}',
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.flag_rounded, color: theme.colorScheme.primary, size: 32),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.milestone.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      widget.milestone.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildStatsRow(theme),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tasks', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        TextButton.icon(
                          onPressed: _showAddTaskDialog,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Task'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (tasks.isEmpty)
                       const Center(child: Padding(
                         padding: EdgeInsets.all(20.0),
                         child: Text('No tasks found for this milestone.'),
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
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            theme, 
            'Progress', 
            '${(widget.milestone.progress * 100).toInt()}%', 
            Icons.donut_large_rounded
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatItem(
            theme, 
            'Tasks', 
            '${widget.milestone.completedTasks}/${widget.milestone.totalTasks}', 
            Icons.check_circle_outline_rounded
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
