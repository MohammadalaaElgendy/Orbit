import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/orbit_logo.dart';
import '../../../../shared/widgets/orbit_button.dart';
import '../../../../shared/widgets/orbit_text_field.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../view_models/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription? _loginSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      _loginSubscription = authViewModel.loginSuccessStream.listen((success) {
        if (success && mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      });
    });
  }

  @override
  void dispose() {
    _loginSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: AuthBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + AppSpacing.xl),
                    // Brand Section
                    _buildAnimatedItem(
                      delay: 0,
                      child: Column(
                        children: [
                          const OrbitLogo(size: 64, showGlassBackground: true),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Orbit',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            'SECURE SIGN IN',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 2.0,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Form Card
                    _buildAnimatedItem(
                      delay: 300,
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        borderRadius: AppRadius.xxl,
                        opacity: 0.1,
                        borderColor: Colors.white.withValues(alpha: 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get Started',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Enter your email to receive a sign-in code.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Center(
                              child: GestureDetector(
                                onTap: () => authViewModel.pickAvatar(),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 38,
                                        backgroundColor: theme.colorScheme.surface,
                                        backgroundImage: authViewModel.pickedAvatarBytes != null
                                            ? MemoryImage(authViewModel.pickedAvatarBytes!)
                                            : null,
                                        child: authViewModel.pickedAvatarBytes == null
                                            ? Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary)
                                            : null,
                                      ),
                                    ),
                                    if (authViewModel.pickedAvatarBytes != null)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            OrbitTextField(
                              label: 'Full Name (First time only)',
                              hint: 'Enter your name',
                              controller: authViewModel.nameController,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            OrbitTextField(
                              label: 'Email address',
                              hint: 'Enter your email',
                              controller: authViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (authViewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: Text(
                                  authViewModel.errorMessage!,
                                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                                ),
                              ),
                            OrbitButton(
                              text: 'Send Sign-in Code',
                              isLoading: authViewModel.isLoading,
                              onPressed: () async {
                                await authViewModel.sendOtp();
                                if (authViewModel.errorMessage == null && context.mounted) {
                                  Navigator.pushNamed(context, '/otp');
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Text(
                                    'OR',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            OrbitButton(
                              text: 'Continue with Google',
                              style: OrbitButtonStyle.secondary,
                              icon: Image.asset(
                                'assets/images/auth/google_logo.png',
                                height: 20,
                              ),
                              onPressed: () => authViewModel.signInWithGoogle(),
                            ),
                          ],
                        ),
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
    ));
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
