import 'package:flutter/material.dart';
import '../../../../shared/models/task.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/smart_image.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/user.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final String? milestoneId;
  final String? parentTaskId;
  final List<User> workspaceMembers;
  final Function({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    String? assigneeId,
    DateTime? dueDate,
  }) onSave;

  const TaskDialog({
    super.key,
    this.task,
    this.milestoneId,
    this.parentTaskId,
    this.workspaceMembers = const [],
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskStatus _status;
  late TaskPriority _priority;
  String? _assigneeId;
  DateTime? _dueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _assigneeId = widget.task?.assigneeId;
    _dueDate = widget.task?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.task != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.xl,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Task' : 'Create Task',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.workspaceMembers.isNotEmpty) ...[
                      DropdownButtonFormField<String?>(
                        initialValue: _assigneeId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Assignee',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Unassigned')),
                          ...widget.workspaceMembers.map((u) => DropdownMenuItem(
                            value: u.id, 
                            child: Row(
                              children: [
                                if (u.avatarUrl != null)
                                  ClipOval(
                                    child: SmartImage(
                                      imageUrl: u.avatarUrl!,
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                else
                                  const Icon(Icons.person_outline_rounded, size: 16),
                                const SizedBox(width: AppSpacing.sm),
                                Text(u.name),
                              ],
                            )
                          )),
                        ],
                        onChanged: (v) => setState(() => _assigneeId = v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TaskStatus>(
                            initialValue: _status,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<TaskPriority>(
                            initialValue: _priority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                            onChanged: (v) => setState(() => _priority = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) setState(() => _dueDate = date);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          suffixIcon: _dueDate != null 
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => setState(() => _dueDate = null),
                              )
                            : const Icon(Icons.calendar_today_rounded, size: 18),
                        ),
                        child: Text(_dueDate == null ? 'Not set' : DateFormat('MMM dd, yyyy').format(_dueDate!)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              widget.onSave(
                                title: _titleController.text,
                                description: _descController.text,
                                status: _status,
                                priority: _priority,
                                assigneeId: _assigneeId,
                                dueDate: _dueDate,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                          child: Text(isEdit ? 'Save' : 'Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
