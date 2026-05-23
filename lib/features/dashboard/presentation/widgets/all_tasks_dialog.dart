import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../view_models/dashboard_view_model.dart';
import 'task_card.dart';

class AllTasksDialog extends StatelessWidget {
  const AllTasksDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTasks = context.watch<DashboardViewModel>().allTasks;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (allTasks.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No tasks found.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: allTasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TaskCard(task: allTasks[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
