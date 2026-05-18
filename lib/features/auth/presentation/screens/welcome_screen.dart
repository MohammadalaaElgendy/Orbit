import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/orbit_button.dart';
import '../../../../shared/widgets/orbit_logo.dart';

import '../../../../shared/widgets/auth_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _buildAnimatedItem(
                    delay: 0,
                    child: const OrbitLogo(size: 90),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAnimatedItem(
                    delay: 200,
                    child: Text(
                      'Orbit',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -3.0,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildAnimatedItem(
                    delay: 400,
                    child: Text(
                      'Your focus, elevated.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 4),
                  _buildAnimatedItem(
                    delay: 600,
                    child: OrbitButton(
                      text: 'Launch Workspace',
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildAnimatedItem(
                    delay: 800,
                    child: OrbitButton(
                      text: 'Sign In to Orbit',
                      style: OrbitButtonStyle.secondary,
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600), // Speed up from 1000ms
      curve: Interval(
        (delay / 1500).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutQuart,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Subtler move
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
