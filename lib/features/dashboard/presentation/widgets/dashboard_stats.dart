import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            blur: 5,
            frosted: true,
            borderRadius: AppRadius.xxl,
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              children: [
                _buildProductivityPulse(theme),
                if (isWide) 
                  Container(width: 1, height: 80, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))
                else 
                  const SizedBox(height: AppSpacing.xl),
                Expanded(
                  flex: isWide ? 2 : 0,
                  child: _buildGoalInsights(theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductivityPulse(ThemeData theme) {
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
                value: 0.72,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  '72%', 
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'DONE', 
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10, // Increased from 8
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
          'Weekly Output', 
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14, // Explicitly set
          ),
        ),
      ],
    );
  }

  Widget _buildGoalInsights(ThemeData theme) {
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
                fontSize: 12, // Increased from default
              ),
            ),
            Text(
              '4/6 Milestones', 
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMiniProgressRow(theme, 'Development', 0.8, Colors.blueAccent),
        const SizedBox(height: AppSpacing.md), // Increased spacing
        _buildMiniProgressRow(theme, 'Design Review', 0.4, Colors.purpleAccent),
        const SizedBox(height: AppSpacing.md),
        _buildMiniProgressRow(theme, 'Final Testing', 0.1, Colors.orangeAccent),
      ],
    );
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
                  fontSize: 13, // Increased from 10
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%', 
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13, // Increased from 10
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
