import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user.dart';
import '../view_models/workspace_view_model.dart';

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
          _error = 'User not found';
        }
      });
    } catch (e) {
      setState(() => _error = 'An error occurred');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Member', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _emailController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. john@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  suffixIcon: _isSearching 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: Colors.blue),
                        onPressed: _search,
                      ),
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search Database'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              if (_foundUser != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: _foundUser!.avatarUrl != null ? NetworkImage(_foundUser!.avatarUrl!) : null,
                    child: _foundUser!.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(_foundUser!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_foundUser!.email),
                  trailing: ElevatedButton(
                    onPressed: () {
                      context.read<WorkspaceViewModel>().addMember(widget.workspaceId, _foundUser!.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
