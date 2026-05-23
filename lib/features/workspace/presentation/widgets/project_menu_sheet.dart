import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/workspace_view_model.dart';
import 'project_dialog.dart';

class ProjectMenuSheet extends StatelessWidget {
  final Project project;

  const ProjectMenuSheet({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WorkspaceViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text('Edit Project'),
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
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          title: const Text('Delete Project', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: 'Delete Project',
                message: 'Are you sure you want to delete "${project.name}"?',
                confirmLabel: 'Delete',
                confirmColor: Colors.red,
                onConfirm: () => viewModel.deleteProject(project.id),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
