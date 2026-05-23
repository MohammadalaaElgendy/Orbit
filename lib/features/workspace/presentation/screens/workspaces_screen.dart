import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/presentation/view_models/dashboard_view_model.dart';
import '../../../dashboard/presentation/widgets/workspace_card.dart';
import 'package:orbit/shared/widgets/top_padding.dart';
import '../../../../l10n/app_localizations.dart';

class WorkspacesScreen extends StatelessWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<DashboardViewModel>();
    final workspaces = viewModel.workspaces;
    final l10n = AppLocalizations.of(context)!;

    if (workspaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline_rounded, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              l10n.noWorkspaces,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: TopPadding()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 180,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ws = workspaces[index];
                    final members = viewModel.workspaceMembersMap[ws.id] ?? [];
                    return WorkspaceCard(
                      ws: ws,
                      isDark: isDark,
                      members: members,
                    );
                  },
                  childCount: workspaces.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: BottomPadding()),
          ],
        );
      },
    );
  }
}
