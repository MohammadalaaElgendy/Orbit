import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum OrbitButtonStyle { primary, secondary, ghost }

class OrbitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final OrbitButtonStyle style;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const OrbitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = OrbitButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(text),
        ],
      ],
    );

    final isDark = theme.brightness == Brightness.dark;
    
    // Premium adaptive colors
    final primaryBg = isDark ? Colors.white : theme.colorScheme.primary;
    final primaryText = isDark ? const Color(0xFF0F0069) : Colors.white;
    
    // In light mode, let's keep the button premium with a subtle glow instead of flat
    final primaryShadow = isDark 
        ? Colors.black.withValues(alpha: 0.15) 
        : theme.colorScheme.primary.withValues(alpha: 0.3);

    final secondaryBg = isDark 
        ? Colors.white.withValues(alpha: 0.08) 
        : Colors.white.withValues(alpha: 0.6); // Frosted secondary
        
    final secondaryText = isDark ? Colors.white : theme.colorScheme.primary;
    final secondaryBorder = isDark 
        ? Colors.white.withValues(alpha: 0.2) 
        : theme.colorScheme.primary.withValues(alpha: 0.3);

    switch (style) {
      case OrbitButtonStyle.primary:
        return Center(
          child: SizedBox(
            width: fullWidth ? double.infinity : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: primaryShadow,
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: isLoading ? null : onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryBg,
                    foregroundColor: primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  child: buttonChild,
                ),
              ),
            ),
          ),
        );
      case OrbitButtonStyle.secondary:
        return Center(
          child: SizedBox(
            width: fullWidth ? double.infinity : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: OutlinedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: secondaryBg,
                    foregroundColor: secondaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: secondaryBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: buttonChild,
                ),
              ),
            ),
          ),
        );
      case OrbitButtonStyle.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          ),
        );
    }
  }
}
