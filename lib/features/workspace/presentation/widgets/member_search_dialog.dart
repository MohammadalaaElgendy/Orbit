import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user.dart';
import '../view_models/workspace_view_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/orbit_button.dart';

class MemberSearchDialog extends StatefulWidget {
  final String workspaceId;

  const MemberSearchDialog({super.key, required this.workspaceId});

  @override
  State<MemberSearchDialog> createState() => _MemberSearchDialogState();
}

class _MemberSearchDialogState extends State<MemberSearchDialog> {
  final _emailController = TextEditingController();
  User? _foundUser;
  bool _isSearching = false;
  String? _error;

  void _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isSearching = true;
      _foundUser = null;
      _error = null;
    });

    try {
      final user = await context.read<WorkspaceViewModel>().searchUserByEmail(email);
      if (!mounted) return;

      setState(() {
        _foundUser = user;
        if (user == null) {
          _error = 'User not found in our database.';
        }
      });
    } catch (e) {
      setState(() => _error = 'An unexpected error occurred.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.xxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.person_add_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Add Member', 
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Enter the email address of the person you want to invite to this workspace.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _emailController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter user email',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  suffixIcon: _emailController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => setState(() => _emailController.clear()),
                      )
                    : null,
                ),
                onChanged: (val) => setState(() {}),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: AppSpacing.lg),
              OrbitButton(
                text: 'Search Member',
                onPressed: _search,
                isLoading: _isSearching,
                icon: const Icon(Icons.search_rounded, size: 20),
              ),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSearchResult(theme),
              ),

              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                child: const Text('Maybe later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult(ThemeData theme) {
    if (_isSearching) return const SizedBox.shrink();

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _error!, 
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_foundUser != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Found', 
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _foundUser!.avatarUrl != null ? NetworkImage(_foundUser!.avatarUrl!) : null,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: _foundUser!.avatarUrl == null 
                      ? Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer) 
                      : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _foundUser!.name, 
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _foundUser!.email, 
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OrbitButton(
                    text: 'Add',
                    fullWidth: false,
                    onPressed: () {
                      context.read<WorkspaceViewModel>().addMember(widget.workspaceId, _foundUser!.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
