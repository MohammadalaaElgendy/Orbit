import 'package:flutter/material.dart';
import '../../../../shared/models/project.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';

import '../../../../l10n/app_localizations.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project;
  final String? workspaceId;
  final Function(String name, String description, String color) onSave;

  const ProjectDialog({super.key, this.project, this.workspaceId, required this.onSave});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedColor;
  final _formKey = GlobalKey<FormState>();

  final List<String> _colors = [
    '#6366F1', // Indigo
    '#3B82F6', // Blue
    '#10B981', // Emerald
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#EC4899', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? _colors[0];
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
    final isEdit = widget.project != null;
    final l10n = AppLocalizations.of(context)!;

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
                          isEdit ? Icons.edit_note_rounded : Icons.rocket_launch_rounded, 
                          color: theme.colorScheme.primary, 
                          size: 28
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          isEdit ? l10n.editProject : l10n.newProject,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _nameController,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l10n.projectName,
                        hintText: l10n.projectNameHint,
                        prefixIcon: const Icon(Icons.folder_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? l10n.pleaseEnterProjectName : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionLabel,
                        hintText: l10n.projectDescriptionHint,
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.projectThemeColor, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colors.length,
                        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final colorHex = _colors[index];
                          final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                          final isSelected = _selectedColor == colorHex;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = colorHex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 48 : 40,
                              height: isSelected ? 48 : 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                                boxShadow: isSelected ? [
                                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
                                ] : null,
                              ),
                              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              widget.onSave(_nameController.text, _descController.text, _selectedColor);
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
                          child: Text(isEdit ? l10n.saveChanges : l10n.newProject, style: const TextStyle(fontWeight: FontWeight.bold)),
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
