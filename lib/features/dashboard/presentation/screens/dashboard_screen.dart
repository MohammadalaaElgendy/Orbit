import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/widgets/glass_card.dart';
import 'package:orbit/shared/widgets/responsive_scaffold.dart';
import 'package:orbit/features/dashboard/presentation/widgets/dashboard_stats.dart';
import 'package:orbit/features/dashboard/presentation/widgets/workspace_card.dart';
import 'package:orbit/features/dashboard/presentation/widgets/milestone_card.dart';
import 'package:orbit/features/dashboard/presentation/widgets/task_card.dart';
import 'package:orbit/features/dashboard/presentation/widgets/all_tasks_dialog.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:orbit/features/workspace/presentation/widgets/workspace_dialog.dart';
import 'package:orbit/shared/widgets/top_padding.dart';

class DashboardScreen extends StatelessWidget {
  final bool isTab;
  const DashboardScreen({super.key, this.isTab = false});

  void _showCreateWorkspace(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WorkspaceDialog(
        onSave: (name, desc, imageUrl, memberIds) => context.read<DashboardViewModel>().createWorkspace(name, desc, imageUrl, memberIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<DashboardViewModel>();

    final workspaces = viewModel.workspaces;
    final milestones = viewModel.recentMilestones;
    final tasks = viewModel.recentTasks;

    final body = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopPadding(),
          const DashboardStats(),
          
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(theme, 'Active Workspaces', '${workspaces.length} total'),
          const SizedBox(height: AppSpacing.md),

          workspaces.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('No workspaces found'),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              // Mobile Layout
              if (isMobile) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: workspaces.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final ws = workspaces[index];
                      final members =
                          viewModel.workspaceMembersMap[ws.id] ?? [];

                      return WorkspaceCard(
                        ws: ws,
                        isDark: isDark,
                        members: members,
                      );
                    },
                  ),
                );
              }

              // Desktop / Tablet Layout
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workspaces.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350, // العرض ديناميك
                    mainAxisExtent: 180, // ارتفاع ثابت
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) {
                    final ws = workspaces[index];
                    final members =
                        viewModel.workspaceMembersMap[ws.id] ?? [];

                    return WorkspaceCard(
                      ws: ws,
                      isDark: isDark,
                      members: members,
                    );
                  },
                ),
              );
            },
          ),

          if (milestones.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(theme, 'Priority Milestones', 'Recent'),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: milestones.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: MilestoneCard(milestone: m),
                )).toList(),
              ),
            ),
          ],

          if (tasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(
              theme, 
              'Recent Activity', 
              'View all', 
              onTap: () => showDialog(
                context: context,
                builder: (_) => const AllTasksDialog(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: tasks.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: TaskCard(task: t),
                )).toList(),
              ),
            ),
          ],
          const BottomPadding(),
        ],
      ),
    );

    if (isTab) return body;

    return ResponsiveScaffold(
      title: 'My Dashboard',
      actions: [
        // No manual SizedBox needed anymore, Scaffold handles it via Directional Padding
        _buildActionButton(
          context, 
          icon: Icons.add_rounded, 
          onTap: () => _showCreateWorkspace(context),
        ),
        _buildActionButton(
          context, 
          icon: Icons.search, 
          onTap: () {},
        ),
      ],
      body: body,
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.md,
      blur: 10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              subtitle, 
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}
