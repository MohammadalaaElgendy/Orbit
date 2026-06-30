import 'package:flutter/material.dart';
import 'smart_image.dart';

class OrbitAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData placeholderIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const OrbitAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.placeholderIcon = Icons.person,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = radius * 2;

    // Determine default background color based on theme
    final Color defaultBgColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
        : theme.colorScheme.primary.withValues(alpha: 0.9);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? defaultBgColor,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? SmartImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
              )
            : Icon(
                placeholderIcon,
                size: radius,
                color: foregroundColor ?? Colors.white,
              ),
      ),
    );
  }
}
