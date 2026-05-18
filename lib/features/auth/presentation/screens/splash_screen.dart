import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/orbit_logo.dart';
import '../view_models/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    
    if (authViewModel.user != null) {
      if (authViewModel.user!.isVerified) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // If logged in but not verified (shouldn't happen with current flow, 
        // but good for safety), go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand Identity (Premium Splash Style)
              const OrbitLogo(size: 100),
              const SizedBox(height: 32),
              Column(
                children: [
                  Text(
                    'Orbit',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 64,
                      letterSpacing: -3.0,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your focus, elevated.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
