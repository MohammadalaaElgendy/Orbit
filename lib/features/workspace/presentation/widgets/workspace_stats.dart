import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../view_models/workspace_view_model.dart';
import '../../../../l10n/app_localizations.dart';

class WorkspaceStats extends StatelessWidget {
  const WorkspaceStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          blur: 3,
          frosted: true,
          borderRadius: AppRadius.xxl,
          child: Selector<WorkspaceViewModel, ({double progress, int total, int completed, List topMilestones})>(
            selector: (_, vm) => (
              progress: vm.overallProgress,
              total: vm.totalMilestones,
              completed: vm.completedMilestones,
              topMilestones: vm.topMilestones,
            ),
            builder: (context, data, _) {
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                children: [
                  _buildProductivityPulse(theme, data.progress, l10n),
                  if (isWide) 
                    Container(width: 1, height: 80, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))
                  else 
                    const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    flex: isWide ? 2 : 0,
                    child: _buildGoalInsights(theme, data.topMilestones, data.completed, data.total, l10n),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductivityPulse(ThemeData theme, double progress, AppLocalizations l10n) {
    final percentage = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  '$percentage%', 
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  l10n.done, 
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.totalProductivity, 
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalInsights(ThemeData theme, List topMilestones, int completed, int total, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.goalProgress, 
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5, 
                fontWeight: FontWeight.w900, 
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
            Text(
              '$completed/$total ${l10n.milestones}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (topMilestones.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              l10n.noActiveMilestones,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          ...topMilestones.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildMiniProgressRow(theme, m.name, m.progress, _getMilestoneColor(m.progress)),
          )),
      ],
    );
  }

  Color _getMilestoneColor(double progress) {
    if (progress >= 1.0) return Colors.purpleAccent;
    if (progress >= 0.90) return Colors.blueAccent;
    if (progress >= 0.80) return Colors.cyanAccent;
    if (progress >= 0.70) return Colors.tealAccent;
    if (progress >= 0.60) return Colors.greenAccent;
    if (progress >= 0.50) return Colors.limeAccent;
    if (progress >= 0.40) return Colors.yellowAccent;
    if (progress >= 0.30) return Colors.amberAccent;
    if (progress >= 0.20) return Colors.orangeAccent;
    if (progress >= 0.10) return Colors.deepOrangeAccent;
    return Colors.redAccent;
  }

  Widget _buildMiniProgressRow(ThemeData theme, String label, double value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label, 
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%', 
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
