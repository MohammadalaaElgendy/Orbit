import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/workspace_view_model.dart';
import 'workspace_dialog.dart';

class WorkspaceMenuSheet extends StatelessWidget {
  final Workspace workspace;
  final VoidCallback? onDelete;

  const WorkspaceMenuSheet({
    super.key,
    required this.workspace,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WorkspaceViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text('Edit Workspace'),
          onTap: () async {
            Navigator.pop(context);
            final members = await viewModel.getWorkspaceMembers(workspace.id);
            if (!context.mounted) return;
            
            showDialog(
              context: context,
              builder: (_) => WorkspaceDialog(
                workspace: workspace,
                currentMembers: members,
                onSave: (name, desc, imageUrl, memberIds) => viewModel.updateWorkspace(
                  workspace.id, name, desc, imageUrl, memberIds,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          title: const Text('Delete Workspace', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: 'Delete Workspace',
                message: 'Are you sure you want to delete "${workspace.name}"? This action will hide it from your dashboard.',
                confirmLabel: 'Delete',
                confirmColor: Colors.red,
                onConfirm: () {
                  viewModel.deleteWorkspace(workspace.id);
                  onDelete?.call();
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
