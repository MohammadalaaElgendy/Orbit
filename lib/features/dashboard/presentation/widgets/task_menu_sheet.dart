import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/task_view_model.dart';
import 'task_dialog.dart';
import '../../../../l10n/app_localizations.dart';

class TaskMenuSheet extends StatelessWidget {
  final Task task;

  const TaskMenuSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: Text(l10n.editTaskLabel),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => TaskDialog(
                task: task,
                workspaceMembers: viewModel.workspaceMembers,
                onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
                  viewModel.updateTask(context, task.copyWith(
                    title: title,
                    description: description,
                    status: status,
                    priority: priority,
                    assigneeId: assigneeId,
                    updatedAt: DateTime.now(),
                    dueDate: dueDate,
                  ));
                },
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          title: Text(l10n.deleteTask, style: const TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: l10n.deleteTask,
                message: l10n.deleteTaskConfirm(task.title),
                confirmLabel: l10n.delete,
                confirmColor: Colors.red,
                onConfirm: () => viewModel.deleteTask(task.id),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
