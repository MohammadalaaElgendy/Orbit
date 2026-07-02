import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/workspace_view_model.dart';
import 'project_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';

class ProjectMenuSheet extends StatelessWidget {
  final Project project;

  const ProjectMenuSheet({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WorkspaceViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text(l10n.editProjectLabel),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => ProjectDialog(
                  project: project,
                  onSave: (name, desc, color) {
                    viewModel.updateProject(project.copyWith(
                      name: name,
                      description: desc,
                      color: color,
                      updatedAt: DateTime.now(),
                    ));
                  },
                ),
              );
            },
          ),
          if (viewModel.isAdmin)
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: Text(l10n.deleteProject, style: const TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: l10n.deleteProject,
                  message: l10n.deleteProjectConfirm(project.name),
                  confirmLabel: l10n.delete,
                  confirmColor: Colors.red,
                  onConfirm: () => viewModel.deleteProject(project.id),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
