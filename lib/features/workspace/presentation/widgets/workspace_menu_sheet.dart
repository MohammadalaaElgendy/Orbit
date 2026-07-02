import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/workspace_view_model.dart';
import 'workspace_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';

class WorkspaceMenuSheet extends StatefulWidget {
  final Workspace workspace;
  final VoidCallback? onDelete;

  const WorkspaceMenuSheet({
    super.key,
    required this.workspace,
    this.onDelete,
  });

  @override
  State<WorkspaceMenuSheet> createState() => _WorkspaceMenuSheetState();
}

class _WorkspaceMenuSheetState extends State<WorkspaceMenuSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkspaceViewModel>().loadWorkspace(widget.workspace.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkspaceViewModel>();
    final l10n = AppLocalizations.of(context)!;
    
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = widget.workspace.ownerId == currentUserId;
    final isAdmin = isOwner || viewModel.isAdmin;

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(l10n.editWorkspace),
              onTap: () async {
                Navigator.pop(context);
                final members = await viewModel.getWorkspaceMembers(widget.workspace.id);
                if (!context.mounted) return;
                
                showDialog(
                  context: context,
                  builder: (_) => WorkspaceDialog(
                    workspace: widget.workspace,
                    currentMembers: members,
                    onSave: (name, desc, imageUrl, memberIds) => viewModel.updateWorkspace(
                      widget.workspace.id, name, desc, imageUrl, memberIds,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: Text(l10n.deleteWorkspace, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: l10n.deleteWorkspace,
                    message: l10n.deleteWorkspaceConfirm(widget.workspace.name),
                    confirmLabel: l10n.delete,
                    confirmColor: Colors.red,
                    onConfirm: () {
                      viewModel.deleteWorkspace(widget.workspace.id);
                      widget.onDelete?.call();
                    },
                  ),
                );
              },
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
