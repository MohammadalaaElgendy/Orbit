import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/widgets/glass_card.dart';
import 'package:orbit/shared/widgets/responsive_scaffold.dart';
import 'package:orbit/features/dashboard/presentation/widgets/dashboard_stats.dart';
import 'package:orbit/features/dashboard/presentation/widgets/workspace_card.dart';
import 'package:orbit/features/dashboard/presentation/widgets/milestone_card.dart';
import 'package:orbit/features/dashboard/presentation/widgets/task_card.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:orbit/features/workspace/presentation/widgets/workspace_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return ResponsiveScaffold(
      title: 'My Dashboard',
      actions: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xs),
          borderRadius: AppRadius.md,
          blur: 10,
          child: IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: () => _showCreateWorkspace(context),
            tooltip: 'Create Workspace',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xs),
          borderRadius: AppRadius.md,
          blur: 10,
          child: IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: isMobile ? kToolbarHeight + 40 : AppSpacing.md,
          bottom: 120, // Increased to clear floating FAB/BottomNav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardStats(),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(theme, 'Active Workspaces', '${workspaces.length} total'),
            const SizedBox(height: AppSpacing.md),
            
            workspaces.isEmpty
              ? const Center(child: Text('No workspaces found'))
              : isMobile 
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      scrollDirection: Axis.horizontal,
                      itemCount: workspaces.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final ws = workspaces[index];
                        final members = viewModel.workspaceMembersMap[ws.id] ?? [];
                        return WorkspaceCard(
                          ws: ws, 
                          isDark: isDark,
                          members: members,
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Dynamically calculate columns based on width
                        int crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                        final spacing = AppSpacing.md;
                        final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                        
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: workspaces.map((ws) {
                            final members = viewModel.workspaceMembersMap[ws.id] ?? [];
                            return WorkspaceCard(
                              ws: ws, 
                              isDark: isDark, 
                              width: itemWidth,
                              members: members,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

            if (milestones.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildSectionHeader(theme, 'Priority Milestones', 'Coming soon'),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: milestones.map((m) => MilestoneCard(milestone: m)).toList(),
                ),
              ),
            ],

            if (tasks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildSectionHeader(theme, 'Recent Activity', 'View all'),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: tasks.map((t) => TaskCard(task: t)).toList(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
