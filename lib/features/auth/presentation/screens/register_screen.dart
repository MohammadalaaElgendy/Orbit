import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/orbit_button.dart';
import '../../../../shared/widgets/orbit_text_field.dart';

import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/orbit_logo.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildAnimatedItem(
                      delay: 0,
                      child: const OrbitLogo(size: 64),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildAnimatedItem(
                      delay: 200,
                      child: Column(
                        children: [
                          const Text(
                            'Join Orbit', 
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            'Elevate your productivity baseline.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAnimatedItem(
                      delay: 400,
                      child: GlassCard(
                        opacity: 0.1,
                        borderColor: Colors.white.withValues(alpha: 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const OrbitTextField(
                              label: 'Full Name',
                              hint: 'John Doe',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const OrbitTextField(
                              label: 'Email address',
                              hint: 'name@company.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const OrbitTextField(
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            OrbitButton(
                              text: 'Create Account',
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                      _buildAnimatedItem(
                        delay: 600,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: Text(
                                'Sign In',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
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
      duration: const Duration(milliseconds: 600),
      curve: Interval(
        (delay / 1500).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutQuart,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
