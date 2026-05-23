import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/orbit_logo.dart';
import '../../../../shared/widgets/orbit_button.dart';
import '../../../../shared/widgets/orbit_text_field.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../view_models/auth_view_model.dart';
import '../../../../l10n/app_localizations.dart';

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
      
      // Check if user is already logged in (e.g. from a very fast deep link response)
      if (authViewModel.user != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        return;
      }

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
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      child: AuthBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
            ),
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
                            l10n.appTitle,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            l10n.secureSignIn,
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
                              l10n.getStarted,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.emailDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (authViewModel.userExists == false) ...[
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
                                        child: ClipOval(
                                          child: authViewModel.pickedAvatarBytes != null
                                              ? Image.memory(
                                                  authViewModel.pickedAvatarBytes!,
                                                  fit: BoxFit.cover,
                                                  width: 76,
                                                  height: 76,
                                                )
                                              : Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary),
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
                                label: l10n.fullNameLabel,
                                hint: l10n.fullNameHint,
                                controller: authViewModel.nameController,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            OrbitTextField(
                              label: l10n.emailAddressLabel,
                              hint: l10n.emailAddressHint,
                              controller: authViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (authViewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - value) * -10),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: GlassCard(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                    borderRadius: AppRadius.lg,
                                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                                    borderColor: Colors.red.withValues(alpha: 0.2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            authViewModel.errorMessage!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11, // تصغير بسيط عشان الكلام يظهر كله
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                          onPressed: () => authViewModel.clearError(),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            OrbitButton(
                              text: authViewModel.userExists == null ? l10n.continueButton : (authViewModel.userExists! ? l10n.sendCodeButton : l10n.registerAndSendCodeButton),
                              isLoading: authViewModel.isLoading,
                              onPressed: () async {
                                if (authViewModel.userExists == null) {
                                  await authViewModel.checkUserExistence();
                                  if (authViewModel.userExists == true && context.mounted) {
                                    Navigator.pushNamed(context, '/otp');
                                  }
                                } else {
                                  await authViewModel.sendOtp();
                                  if (authViewModel.errorMessage == null && context.mounted) {
                                    Navigator.pushNamed(context, '/otp');
                                  }
                                }
                              },
                            ),
                            if (!kIsWeb) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: Text(
                                      l10n.or,
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
                                text: l10n.continueWithGoogle,
                                style: OrbitButtonStyle.secondary,
                                icon: Image.asset(
                                  'assets/images/auth/google_logo.png',
                                  height: 20,
                                ),
                                onPressed: () => authViewModel.signInWithGoogle(),
                              ),
                            ],
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
