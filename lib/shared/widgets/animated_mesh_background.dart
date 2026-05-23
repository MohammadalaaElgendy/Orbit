import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({super.key});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    // الحصول على الـ preset الحالي من الـ Provider
    final themePreset = context.watch<ThemeModel>().preset;

    // Premium Adaptive Colors based on current theme and preset
    Color bgColor;
    if (isDark) {
      switch (themePreset) {
        case ThemePreset.alexandria: bgColor = AppColors.alexandriaAuthBG; break;
        case ThemePreset.forest: bgColor = AppColors.forestAuthBG; break;
        case ThemePreset.sunset: bgColor = AppColors.sunsetAuthBG; break;
        case ThemePreset.sunrise: bgColor = AppColors.sunriseAuthBG; break;
        case ThemePreset.lavender: bgColor = AppColors.lavenderAuthBG; break;
        case ThemePreset.classic: bgColor = AppColors.classicAuthBG; break;
      }
    } else {
      bgColor = Colors.white;
    }
    
    final blob1Color = theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2);
    final blob2Color = theme.colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.15);
    final blob3Color = theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.1);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Fluid Blob 1 - Moving in a large organic loop
              _buildAnimatedBlob(
                size: size.width * 1.6,
                color: blob1Color,
                top: -size.height * 0.3 + (math.sin(_controller.value * 2 * math.pi) * 80),
                left: -size.width * 0.4 + (math.cos(_controller.value * 2 * math.pi) * 100),
              ),
              
              // Fluid Blob 2 - Counter-motion
              _buildAnimatedBlob(
                size: size.width * 1.5,
                color: blob2Color,
                bottom: -size.height * 0.2 + (math.cos(_controller.value * 2 * math.pi) * 90),
                right: -size.width * 0.3 + (math.sin(_controller.value * 2 * math.pi) * 70),
              ),
              
              // Fluid Blob 3 - Drifting through the center
              _buildAnimatedBlob(
                size: size.width * 1.0,
                color: blob3Color,
                top: size.height * 0.25 + (math.sin((_controller.value + 0.5) * 2 * math.pi) * 120),
                left: size.width * 0.1 + (math.cos((_controller.value + 0.5) * 2 * math.pi) * 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBlob({
    required double size,
    required Color color,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}
