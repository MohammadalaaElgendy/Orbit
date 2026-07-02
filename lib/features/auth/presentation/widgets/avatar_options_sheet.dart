import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../view_models/auth_view_model.dart';
import '../../../../l10n/app_localizations.dart';

class AvatarOptionsSheet extends StatelessWidget {
  const AvatarOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(authViewModel.user?.avatarUrl == null ? l10n.addPhoto : l10n.changePhoto),
            onTap: () {
              Navigator.pop(context);
              authViewModel.updateProfileAvatar();
            },
          ),
          if (authViewModel.user?.avatarUrl != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text(l10n.removePhoto, style: const TextStyle(color: Colors.redAccent)),
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
