import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/task_view_model.dart';
import 'task_dialog.dart';

class TaskMenuSheet extends StatelessWidget {
  final Task task;

  const TaskMenuSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text('Edit Task'),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => TaskDialog(
                task: task,
                workspaceMembers: viewModel.workspaceMembers,
                onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
                  viewModel.updateTask(task.copyWith(
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
          title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: 'Delete Task',
                message: 'Are you sure you want to delete "${task.title}"?',
                confirmLabel: 'Delete',
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
