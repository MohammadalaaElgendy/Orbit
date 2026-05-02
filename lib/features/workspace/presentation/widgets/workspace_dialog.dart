import 'package:flutter/material.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/models/user.dart';
import 'package:provider/provider.dart';
import '../view_models/workspace_view_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/smart_image.dart';

class WorkspaceDialog extends StatefulWidget {
  final Workspace? workspace;
  final List<User>? currentMembers;
  final Function(String name, String description, String? imageUrl, List<String> memberIds) onSave;

  const WorkspaceDialog({
    super.key, 
    this.workspace, 
    this.currentMembers,
    required this.onSave
  });

  @override
  State<WorkspaceDialog> createState() => _WorkspaceDialogState();
}

class _WorkspaceDialogState extends State<WorkspaceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late ScrollController _imageScrollController;
  String? _selectedImageUrl;
  final List<String> _selectedMemberIds = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace?.name ?? '');
    _descController = TextEditingController(text: widget.workspace?.description ?? '');
    _imageScrollController = ScrollController();
    _selectedImageUrl = widget.workspace?.imageUrl ?? AppPresetImages.images[0];
    
    if (widget.currentMembers != null) {
      _selectedMemberIds.addAll(widget.currentMembers!.map((m) => m.id));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.workspace != null;
    final viewModel = context.watch<WorkspaceViewModel>();
    
    // Remove duplicates from allUsers by ID
    final uniqueUsers = <String, User>{};
    for (var u in viewModel.allUsers) {
      uniqueUsers[u.id] = u;
    }
    final allUsers = uniqueUsers.values.toList();

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
                      height: 110,
                      child: Scrollbar(
                        controller: _imageScrollController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _imageScrollController,
                          padding: const EdgeInsets.only(bottom: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: AppPresetImages.images.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            if (index == 0) {
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
                                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
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

                    const SizedBox(height: AppSpacing.lg),
                    Text('Manage Members', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: allUsers.map((user) {
                          final isSelected = _selectedMemberIds.contains(user.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedMemberIds.add(user.id);
                                } else {
                                  _selectedMemberIds.remove(user.id);
                                }
                              });
                            },
                            secondary: CircleAvatar(
                              radius: 16,
                              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                              child: user.avatarUrl == null ? const Icon(Icons.person, size: 16) : null,
                            ),
                            title: Text(user.name, style: theme.textTheme.bodyMedium),
                            subtitle: Text(user.email, style: theme.textTheme.labelSmall),
                            activeColor: theme.colorScheme.primary,
                            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          );
                        }).toList(),
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
