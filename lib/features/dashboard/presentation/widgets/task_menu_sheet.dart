import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/task_view_model.dart';
import 'task_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';

class TaskMenuSheet extends StatefulWidget {
  final Task task;

  const TaskMenuSheet({super.key, required this.task});

  @override
  State<TaskMenuSheet> createState() => _TaskMenuSheetState();
}

class _TaskMenuSheetState extends State<TaskMenuSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskViewModel>().loadTaskDetails(widget.task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskViewModel>();
    final currentTask = viewModel.currentTask ?? widget.task;
    final l10n = AppLocalizations.of(context)!;

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Quick Actions
          if (currentTask.status != TaskStatus.done)
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              title: Text(l10n.statusDone, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                viewModel.updateTask(context, currentTask.copyWith(
                  status: TaskStatus.done,
                  updatedAt: DateTime.now(),
                ));
              },
            ),
          if (currentTask.status != TaskStatus.inProgress)
            ListTile(
              leading: const Icon(Icons.pending_actions_rounded, color: Colors.orange),
              title: Text(l10n.statusInProgress, style: const TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                viewModel.updateTask(context, currentTask.copyWith(
                  status: TaskStatus.inProgress,
                  updatedAt: DateTime.now(),
                ));
              },
            ),
          if (currentTask.status != TaskStatus.todo)
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked_rounded, color: Colors.blue),
              title: Text(l10n.statusTodo, style: const TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.pop(context);
                viewModel.updateTask(context, currentTask.copyWith(
                  status: TaskStatus.todo,
                  updatedAt: DateTime.now(),
                ));
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text(l10n.editTaskLabel),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => TaskDialog(
                  task: currentTask,
                  workspaceMembers: viewModel.workspaceMembers,
                  onSave: ({required description, required priority, required status, required title, assigneeId, dueDate}) {
                    viewModel.updateTask(context, currentTask.copyWith(
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
                  message: l10n.deleteTaskConfirm(currentTask.title),
                  confirmLabel: l10n.delete,
                  confirmColor: Colors.red,
                  onConfirm: () => viewModel.deleteTask(currentTask.id),
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
