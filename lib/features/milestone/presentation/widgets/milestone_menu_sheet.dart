import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/milestone_view_model.dart';
import 'milestone_dialog.dart';
import '../../../../l10n/app_localizations.dart';

class MilestoneMenuSheet extends StatelessWidget {
  final Milestone milestone;

  const MilestoneMenuSheet({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MilestoneViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: Text(l10n.editMilestone),
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
          title: Text(l10n.deleteMilestone, style: const TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: l10n.deleteMilestone,
                message: l10n.deleteMilestoneConfirm(milestone.name),
                confirmLabel: l10n.delete,
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
