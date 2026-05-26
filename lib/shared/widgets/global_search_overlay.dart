import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'package:provider/provider.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:orbit/shared/models/workspace.dart';
import 'package:orbit/shared/models/milestone.dart';
import 'package:orbit/shared/models/task.dart';
import 'package:orbit/l10n/app_localizations.dart';

class GlobalSearchOverlay extends StatefulWidget {
  const GlobalSearchOverlay({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const GlobalSearchOverlay();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends State<GlobalSearchOverlay> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredWorkspaces = viewModel.workspaces
        .where((w) => w.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final filteredMilestones = viewModel.allMilestones
        .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final filteredTasks = viewModel.allTasks
        .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final hasResults = filteredWorkspaces.isNotEmpty ||
        filteredMilestones.isNotEmpty ||
        filteredTasks.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.2 : 0.4),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context, l10n, theme),
              Expanded(
                child: _query.isEmpty
                    ? _buildSuggestions(l10n, theme)
                    : hasResults
                        ? _buildResults(
                            filteredWorkspaces,
                            filteredMilestones,
                            filteredTasks,
                            l10n,
                            theme,
                          )
                        : _buildNoResults(l10n, theme),
              ),
            ],
          ),
        ),
      ).asGlass(
        blurX: 20,
        blurY: 20,
        tileMode: TileMode.clamp,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.searchAnything,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.searchSuggestions,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    List<Workspace> workspaces,
    List<Milestone> milestones,
    List<Task> tasks,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        if (workspaces.isNotEmpty) ...[
          _buildSectionHeader(l10n.workspaces, theme),
          ...workspaces.map((w) => _buildResultTile(
                title: w.name,
                subtitle: l10n.workspace,
                icon: Icons.work_outline_rounded,
                onTap: () => Navigator.pushNamed(context, '/workspace-details', arguments: w),
              )),
        ],
        if (milestones.isNotEmpty) ...[
          _buildSectionHeader(l10n.milestones, theme),
          ...milestones.map((m) => _buildResultTile(
                title: m.name,
                subtitle: '${l10n.milestone} • ${m.projectName ?? ""}',
                icon: Icons.flag_outlined,
                onTap: () => Navigator.pushNamed(context, '/milestone-details', arguments: m),
              )),
        ],
        if (tasks.isNotEmpty) ...[
          _buildSectionHeader(l10n.tasks, theme),
          ...tasks.map((t) => _buildResultTile(
                title: t.title,
                subtitle: l10n.task,
                icon: Icons.check_circle_outline_rounded,
                onTap: () => Navigator.pushNamed(context, '/task-details', arguments: t),
              )),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildResultTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // لضمان قص المحتوى والظلال على الحدود
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: theme.textTheme.labelSmall),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
        ),
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Text(
        l10n.noResultsFound,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
