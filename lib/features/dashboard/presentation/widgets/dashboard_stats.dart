import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<DashboardViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md), // Reduced from lg
            blur: 5,
            frosted: true,
            borderRadius: AppRadius.xxl,
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              children: [
                _buildProductivityPulse(theme, viewModel),
                if (isWide) 
                  Container(width: 1, height: 80, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))
                else 
                  const SizedBox(height: AppSpacing.xl),
                Expanded(
                  flex: isWide ? 2 : 0,
                  child: _buildGoalInsights(theme, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductivityPulse(ThemeData theme, DashboardViewModel viewModel) {
    final progress = viewModel.overallProgress;
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
                  'DONE', 
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
          'Total Productivity', 
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalInsights(ThemeData theme, DashboardViewModel viewModel) {
    final topMilestones = viewModel.topMilestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GOAL PROGRESS', 
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5, 
                fontWeight: FontWeight.w900, 
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
            Text(
              '${viewModel.completedMilestones}/${viewModel.totalMilestones} Milestones', 
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
              'No active milestones found.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          ...topMilestones.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildMiniProgressRow(theme, m.name, m.progress, _getMilestoneColor(m.name)),
          )),
      ],
    );
  }

  Color _getMilestoneColor(String name) {
    // Deterministic color based on name
    final colors = [Colors.blueAccent, Colors.purpleAccent, Colors.orangeAccent, Colors.greenAccent, Colors.pinkAccent];
    return colors[name.length % colors.length];
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
