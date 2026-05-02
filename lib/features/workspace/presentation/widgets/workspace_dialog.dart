import 'package:flutter/material.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../view_models/workspace_view_model.dart';

import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/smart_image.dart';

class WorkspaceDialog extends StatefulWidget {
  final Workspace? workspace;
  final Function(String name, String description, String? imageUrl, List<String> memberIds) onSave;

  const WorkspaceDialog({super.key, this.workspace, required this.onSave});

  @override
  State<WorkspaceDialog> createState() => _WorkspaceDialogState();
}

class _WorkspaceDialogState extends State<WorkspaceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late ScrollController _scrollController;
  String? _selectedImageUrl;
  final List<String> _selectedMemberIds = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace?.name ?? '');
    _descController = TextEditingController(text: widget.workspace?.description ?? '');
    _scrollController = ScrollController();
    _selectedImageUrl = widget.workspace?.imageUrl ?? AppPresetImages.images[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.workspace != null;
    final viewModel = context.watch<WorkspaceViewModel>();
    final allUsers = viewModel.allUsers;

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
                    Text(
                      isEdit ? 'Edit Workspace' : 'Create Workspace',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Orbit Development',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'What is this workspace about?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Select Workspace Image', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 100,
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: AppPresetImages.images.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Custom Image Picker Button
                              return GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() => _selectedImageUrl = image.path);
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 2, style: BorderStyle.solid),
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, color: theme.colorScheme.primary),
                                      const SizedBox(height: 4),
                                      Text('Custom', style: theme.textTheme.labelSmall),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final imageUrl = AppPresetImages.images[index - 1];
                            final isSelected = _selectedImageUrl == imageUrl;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedImageUrl = imageUrl),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 3) : null,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    SmartImage(imageUrl: imageUrl),
                                    if (isSelected)
                                      const Center(child: Icon(Icons.check_circle, color: Colors.white)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text('Invite Members', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: allUsers.map((user) {
                          final isSelected = _selectedMemberIds.contains(user.id);
                          return FilterChip(
                            label: Text(user.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMemberIds.add(user.id);
                                } else {
                                  _selectedMemberIds.remove(user.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
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
                              widget.onSave(_nameController.text, _descController.text, _selectedImageUrl, _selectedMemberIds);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                          child: Text(isEdit ? 'Save Changes' : 'Create'),
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
