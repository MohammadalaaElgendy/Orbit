import 'package:flutter/material.dart';
import '../../../../shared/models/user.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';

class MemberDetailsDialog extends StatelessWidget {
  final User user;

  const MemberDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bool isAdmin = user.role?.toLowerCase() == 'admin';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAdmin ? Colors.amber : theme.colorScheme.primary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Name
            Text(
              user.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            
            // Email
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isAdmin 
                    ? Colors.amber.withValues(alpha: 0.1) 
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isAdmin ? Colors.amber : theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                    size: 16,
                    color: isAdmin ? Colors.amber[700] : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAdmin ? 'Workspace Admin' : 'Member',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: isAdmin ? (isDark ? Colors.amber[200] : Colors.amber[900]) : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3525CD), // نفس لون كبسولة View Details
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  elevation: 4,
                  shadowColor: const Color(0xFF3525CD).withValues(alpha: 0.3),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
