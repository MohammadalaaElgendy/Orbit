import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/milestone_view_model.dart';
import 'milestone_dialog.dart';

class MilestoneMenuSheet extends StatelessWidget {
  final Milestone milestone;

  const MilestoneMenuSheet({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MilestoneViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text('Edit Milestone'),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => MilestoneDialog(
                milestone: milestone,
                onSave: (name, desc, dueDate) {
                  viewModel.updateMilestone(milestone.copyWith(
                    name: name,
                    description: desc,
                    dueDate: dueDate,
                    updatedAt: DateTime.now(),
                  ));
                },
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          title: const Text('Delete Milestone', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: 'Delete Milestone',
                message: 'Are you sure you want to delete "${milestone.name}"?',
                confirmLabel: 'Delete',
                confirmColor: Colors.red,
                onConfirm: () => viewModel.deleteMilestone(milestone.id),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
