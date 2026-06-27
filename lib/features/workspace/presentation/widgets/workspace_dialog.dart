import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../shared/models/workspace.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/models/user.dart';
import 'package:provider/provider.dart';
import '../view_models/workspace_view_model.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../shared/widgets/orbit_avatar.dart';
import '../../../../l10n/app_localizations.dart';

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
  late TextEditingController _searchController;
  late ScrollController _imageScrollController;
  String? _selectedImageUrl;
  String? _currentCustomImageUrl;
  final List<User> _selectedMembers = [];
  List<User> _searchResults = [];
  bool _isSearching = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace?.name ?? '');
    _descController = TextEditingController(text: widget.workspace?.description ?? '');
    _searchController = TextEditingController();
    _imageScrollController = ScrollController();
    _selectedImageUrl = widget.workspace?.imageUrl ?? AppPresetImages.images[0];

    // التحقق مما إذا كانت الصورة الحالية هي صورة مخصصة (ليست من الـ presets)
    if (widget.workspace?.imageUrl != null && !AppPresetImages.images.contains(widget.workspace!.imageUrl)) {
      _currentCustomImageUrl = widget.workspace!.imageUrl;
    }
    
    if (widget.currentMembers != null) {
      _selectedMembers.addAll(widget.currentMembers!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  Widget _buildAddCustomButton(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        // استخدام FilePicker بدلاً من ImagePicker لضمان الاستقرار على الكمبيوتر
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedImageUrl = result.files.single.path!;
            _currentCustomImageUrl = result.files.single.path!; // تحديث المعاينة المخصصة فوراً
          });
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
            Text(l10n.custom, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, ThemeData theme) {
    final isSelected = _selectedImageUrl == imageUrl;
    return GestureDetector(
      onTap: () => setState(() => _selectedImageUrl = imageUrl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              Container(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                child: const Center(child: Icon(Icons.check_circle, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await context.read<WorkspaceViewModel>().searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.workspace != null;
    final l10n = AppLocalizations.of(context)!;
    
    // عدد العناصر الإضافية قبل قائمة الصور الجاهزة (زر الإضافة + الصورة المخصصة الحالية إن وجدت)
    final int indexOffset = _currentCustomImageUrl != null ? 2 : 1;
    
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
                          isEdit ? Icons.edit_note_rounded : Icons.work_outline_rounded,
                          color: theme.colorScheme.primary, 
                          size: 28
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          isEdit ? l10n.editWorkspace : l10n.createWorkspace,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _nameController,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l10n.workspaceName,
                        hintText: l10n.workspaceNameHint,
                        prefixIcon: const Icon(Icons.business_center_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? l10n.pleaseEnterName : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionLabel,
                        hintText: l10n.workspaceNameHint, // Use generic workspace hint
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Text(l10n.workspaceImage, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 110,
                      child: Scrollbar(
                        controller: _imageScrollController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _imageScrollController,
                          padding: const EdgeInsets.only(bottom: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: AppPresetImages.images.length + (indexOffset),
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            // الزر الخاص برفع صورة جديدة
                            if (index == 0) {
                              return _buildAddCustomButton(theme, l10n);
                            }

                            // عرض الصورة المخصصة الحالية إن وجدت لكي تظهر أول واحدة بعد زر الإضافة
                            if (_currentCustomImageUrl != null && index == 1) {
                              return _buildImageItem(_currentCustomImageUrl!, theme);
                            }

                            final presetIndex = index - indexOffset;
                            final imageUrl = AppPresetImages.images[presetIndex];
                            return _buildImageItem(imageUrl, theme);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.teamMembers, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _searchController,
                      onFieldSubmitted: _onSearch,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: l10n.enterEmailHint,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => _onSearch(_searchController.text),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),

                    if (_searchResults.isNotEmpty || _isSearching) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        ),
                        child: _isSearching 
                          ? const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: CircularProgressIndicator(strokeWidth: 2)))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                final isAdded = _selectedMembers.any((m) => m.id == user.id);
                                return ListTile(
                                  leading: OrbitAvatar(
                                    radius: 14,
                                    imageUrl: user.avatarUrl,
                                  ),
                                  title: Text(user.name, style: theme.textTheme.bodyMedium),
                                  subtitle: Text(user.email, style: theme.textTheme.labelSmall),
                                  trailing: IconButton(
                                    icon: Icon(isAdded ? Icons.check_circle : Icons.add_circle_outline, 
                                      color: isAdded ? Colors.green : theme.colorScheme.primary),
                                    onPressed: isAdded ? null : () {
                                      setState(() {
                                        _selectedMembers.add(user);
                                        _searchController.clear();
                                        _searchResults = [];
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                      ),
                    ],

                    if (_selectedMembers.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.selectedMembers, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: _selectedMembers.where((m) {
                            final currentUser = context.read<WorkspaceViewModel>().allUsers.firstWhere(
                              (u) => u.id == Supabase.instance.client.auth.currentUser?.id,
                              orElse: () => m, // Fallback, won't hide if not found but safe
                            );
                            return m.id != currentUser.id;
                          }).map((user) {
                            return CheckboxListTile(
                              value: true,
                              onChanged: (val) {
                                if (val == false) {
                                  setState(() => _selectedMembers.removeWhere((m) => m.id == user.id));
                                }
                              },
                              secondary: OrbitAvatar(
                                radius: 16,
                                imageUrl: user.avatarUrl,
                              ),
                              title: Text(user.name, style: theme.textTheme.bodyMedium),
                              subtitle: Text(user.email, style: theme.textTheme.labelSmall),
                              activeColor: theme.colorScheme.primary,
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            );
                          }).toList(),
                        ),
                      ),
                    ]
                    else if (!isEdit)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(l10n.addMembersStart, style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
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
                              widget.onSave(
                                _nameController.text, 
                                _descController.text, 
                                _selectedImageUrl, 
                                _selectedMembers.map((m) => m.id).toList()
                              );
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
                          child: Text(isEdit ? l10n.saveChanges : l10n.createWorkspace, style: const TextStyle(fontWeight: FontWeight.bold)),
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
