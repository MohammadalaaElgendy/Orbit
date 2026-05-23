import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../view_models/auth_view_model.dart';
import 'avatar_options_sheet.dart';

class UserProfileSheet extends StatelessWidget {
  const UserProfileSheet({super.key});

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;
        final isLoading = authViewModel.isLoading;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        onBackgroundImageError: user?.avatarUrl != null ? (e, s) => debugPrint("Load error") : null,
                        child: user?.avatarUrl == null ? Icon(Icons.person, size: 30, color: theme.colorScheme.primary) : null,
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    if (!isLoading)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: GestureDetector(
                          onTap: () => _showAvatarOptions(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                            ),
                            child: const Icon(Icons.edit, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.name ?? 'User',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                IgnorePointer(
                  ignoring: isLoading,
                  child: Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(Icons.person_outlined, size: 20),
                          title: const Text('Profile Settings', style: TextStyle(fontSize: 13)),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(Icons.palette, size: 20),
                          title: const Text('Appearance', style: TextStyle(fontSize: 13)),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                          onTap: () async {
                            final nav = Navigator.of(context);
                            await authViewModel.logout();
                            nav.pushNamedAndRemoveUntil('/welcome', (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xs),
              ],
            ),
          ),
        );
      },
    );
  }
}
