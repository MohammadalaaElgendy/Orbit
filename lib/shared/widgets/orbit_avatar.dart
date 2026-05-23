import 'package:flutter/material.dart';
import 'smart_image.dart';

class OrbitAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData placeholderIcon;
  final Color? backgroundColor;

  const OrbitAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.placeholderIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
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
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }
}
