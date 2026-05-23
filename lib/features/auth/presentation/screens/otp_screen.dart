import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/orbit_button.dart';
import '../../../../shared/widgets/orbit_pin_field.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/orbit_logo.dart';
import '../view_models/auth_view_model.dart';
import '../../../../l10n/app_localizations.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
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
                    const OrbitLogo(size: 64),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.verification,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      l10n.enterCodeSent(authViewModel.emailController.text),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      opacity: 0.1,
                      borderColor: Colors.white.withValues(alpha: 0.1),
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              l10n.otpCode,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OrbitPinField(
                            controller: authViewModel.otpController,
                            onCompleted: (pin) async {
                              final success = await authViewModel.verifyOtp();
                              if (success && context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                              }
                            },
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
                            text: l10n.verifyAndSignIn,
                            isLoading: authViewModel.isLoading,
                            onPressed: () async {
                              final success = await authViewModel.verifyOtp();
                              if (success && context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
