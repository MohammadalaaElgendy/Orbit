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
    
    // Premium glassmorphism values
    final bgAlpha = isDark ? 0.35 : 0.65; // Balanced for readability and glass effect
    final blurAmount = 25.0; // Deeper blur for premium feel

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
        // Thinner, more subtle border to catch the "light"
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.12) 
              : Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
        // Subtle outer shadow to lift the sheet
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar - refined with better volume
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
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
      frosted: false,
      clipBorderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xxl),
      ),
    );
  }
}
