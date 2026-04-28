import 'package:flutter/material.dart';
import 'glass_card.dart';

class OrbitLogo extends StatelessWidget {
  final double size;
  final bool showGlassBackground;

  const OrbitLogo({
    super.key,
    this.size = 56,
    this.showGlassBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    Widget logoContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showGlassBackground 
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.1) 
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.35),
        border: showGlassBackground ? Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ) : null,
        boxShadow: [
          if (showGlassBackground)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: size * 0.5,
              spreadRadius: -size * 0.1,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner glow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.35),
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.5),
                radius: 0.8,
                colors: [
                  isDark ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Main Icon - Rocket
          Icon(
            Icons.rocket_launch_rounded,
            color: isDark ? Colors.white : theme.colorScheme.primary,
            size: size * 0.55,
          ),
        ],
      ),
    );

    if (!showGlassBackground) return Hero(tag: 'orbit_logo', child: logoContent);

    return Hero(
      tag: 'orbit_logo',
      child: GlassCard(
        padding: EdgeInsets.all(size * 0.2),
        borderRadius: size * 0.5,
        blur: 25,
        opacity: 0.05,
        child: logoContent,
      ),
    );
  }
}
