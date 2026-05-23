import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../view_models/auth_view_model.dart';

class AvatarOptionsSheet extends StatelessWidget {
  const AvatarOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.xxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(authViewModel.user?.avatarUrl == null ? 'Add Photo' : 'Change Photo'),
            onTap: () {
              Navigator.pop(context);
              authViewModel.updateProfileAvatar();
            },
          ),
          if (authViewModel.user?.avatarUrl != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                authViewModel.deleteProfileAvatar();
              },
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
