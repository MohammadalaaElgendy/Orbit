import 'package:flutter/material.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

class MilestoneDialog extends StatefulWidget {
  final Milestone? milestone;
  final String? projectId;
  final Function(String name, String description, DateTime? dueDate) onSave;

  const MilestoneDialog({super.key, this.milestone, this.projectId, required this.onSave});

  @override
  State<MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.milestone?.name ?? '');
    _descController = TextEditingController(text: widget.milestone?.description ?? '');
    _selectedDate = widget.milestone?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.milestone != null;

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
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEdit ? Icons.edit_location_alt_rounded : Icons.flag_circle_rounded, 
                          color: theme.colorScheme.primary, 
                          size: 28
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          isEdit ? 'Edit Milestone' : 'New Milestone',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _nameController,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Milestone Name',
                        hintText: 'e.g., MVP Launch',
                        prefixIcon: const Icon(Icons.outlined_flag_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'What does this milestone achieve?',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  primary: theme.colorScheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Target Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                          suffixIcon: _selectedDate != null 
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => setState(() => _selectedDate = null),
                              )
                            : null,
                        ),
                        child: Text(
                          _selectedDate == null ? 'Set a target date' : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _selectedDate == null ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              widget.onSave(_nameController.text, _descController.text, _selectedDate);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            elevation: 0,
                          ),
                          child: Text(isEdit ? 'Save Changes' : 'Create Milestone', style: const TextStyle(fontWeight: FontWeight.bold)),
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
