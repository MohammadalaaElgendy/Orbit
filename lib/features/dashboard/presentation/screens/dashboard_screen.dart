import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/models/workspace.dart';
import 'package:orbit/shared/models/user.dart';
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
import 'package:orbit/shared/widgets/global_search_overlay.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final body = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: TopPadding()),
        const SliverToBoxAdapter(child: DashboardStats()),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        SliverToBoxAdapter(
          child: Selector<DashboardViewModel, int>(
            selector: (_, vm) => vm.workspaces.length,
            builder: (context, count, _) => _buildSectionHeader(theme, l10n.activeWorkspaces, '$count ${l10n.total}'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        Selector<DashboardViewModel, ({List<Workspace> workspaces, Map<String, List<User>> membersMap})>(
          selector: (_, vm) => (workspaces: vm.workspaces, membersMap: vm.workspaceMembersMap),
          builder: (context, data, _) {
            final workspaces = data.workspaces;
            if (workspaces.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(l10n.noWorkspaces),
                  ),
                ),
              );
            }

            return SliverLayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.crossAxisExtent < 600;

                // Mobile Layout
                if (isMobile) {
                  return SliverToBoxAdapter(
                    child: ConstrainedBox(
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
                          final members = data.membersMap[ws.id] ?? <User>[];

                          return WorkspaceCard(
                            ws: ws,
                            isDark: isDark,
                            members: members,
                          );
                        },
                      ),
                    ),
                  );
                }

                // Desktop / Tablet Layout
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid.builder(
                    itemCount: workspaces.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      mainAxisExtent: 180,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemBuilder: (context, index) {
                      final ws = workspaces[index];
                      final members = data.membersMap[ws.id] ?? <User>[];

                      return WorkspaceCard(
                        ws: ws,
                        isDark: isDark,
                        members: members,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),

        Selector<DashboardViewModel, List>(
          selector: (_, vm) => vm.recentMilestones,
          builder: (context, milestones, _) {
            if (milestones.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverMainAxisGroup(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                SliverToBoxAdapter(child: _buildSectionHeader(theme, l10n.priorityMilestones, l10n.recent)),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: MilestoneCard(milestone: milestones[index]),
                      ),
                      childCount: milestones.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        Selector<DashboardViewModel, List>(
          selector: (_, vm) => vm.recentTasks,
          builder: (context, tasks, _) {
            if (tasks.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverMainAxisGroup(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    theme, 
                    l10n.recentActivity, 
                    l10n.viewAll, 
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AllTasksDialog(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: TaskCard(task: tasks[index]),
                      ),
                      childCount: tasks.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SliverToBoxAdapter(child: BottomPadding()),
      ],
    );

    if (isTab) return body;

    return ResponsiveScaffold(
      title: l10n.dashboard,
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
          onTap: () => GlobalSearchOverlay.show(context),
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
