import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import '../../core/constants/app_constants.dart';

class GlassBottomSheet extends StatelessWidget {
  final Widget child;

  const GlassBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgAlpha = isDark ? 0.15 : 0.35;
    final blurAmount = 18.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: bgAlpha),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    ).asGlass(
      blurX: blurAmount,
      blurY: blurAmount,
      clipBorderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xxl),
      ),
    );
  }
}
