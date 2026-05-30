import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import '../../core/constants/app_constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;
  final double opacity;
  final bool frosted;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.blur = 15.0,
    this.opacity = 0.7, // Matching .glass-card background: rgba(255, 255, 255, 0.7)
    this.frosted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.xxl;
    
    final container = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.45)), // Increased opacity for better "material" feel
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? (isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : theme.colorScheme.primary.withValues(alpha: 0.2)), // Bolder border for definition
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: child,
    );

    return container.asGlass(
      blurX: isDark ? blur : 10.0, // Increased blur in light mode for "frosted" effect
      blurY: isDark ? blur : 10.0,
      clipBorderRadius: BorderRadius.circular(radius),
      frosted: frosted,
      tileMode: TileMode.clamp,
    );
  }
}
