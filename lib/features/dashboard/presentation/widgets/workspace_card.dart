import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/models/workspace.dart';
import 'package:orbit/shared/models/user.dart';
import 'package:orbit/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:orbit/features/workspace/presentation/view_models/workspace_view_model.dart';
import 'package:orbit/features/workspace/presentation/widgets/workspace_dialog.dart';
import 'package:orbit/shared/widgets/smart_image.dart';

class WorkspaceCard extends StatelessWidget {
  final Workspace ws;
  final bool isDark;
  final double? width;
  final List<User> members;

  const WorkspaceCard({
    super.key,
    required this.ws,
    required this.isDark,
    this.width,
    this.members = const [],
  });

  void _showWorkspaceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Workspace'),
            onTap: () async {
              Navigator.pop(context);
              final members = await context.read<WorkspaceViewModel>().getWorkspaceMembers(ws.id);
              if (!context.mounted) return;
              
              showDialog(
                context: context,
                builder: (_) => WorkspaceDialog(
                  workspace: ws,
                  currentMembers: members,
                  onSave: (name, desc, imageUrl, memberIds) => context.read<DashboardViewModel>().updateWorkspace(
                    ws.id, name, desc, imageUrl, memberIds,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Workspace', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Workspace'),
                  content: const Text('Are you sure you want to delete this workspace? This action is reversible but will hide it from your dashboard.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<DashboardViewModel>().deleteWorkspace(ws.id);
                        Navigator.pop(context);
                      }, 
                      child: const Text('Delete', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/workspace-details', arguments: ws),
      child: Container(
        width: width ?? 260,
        height: 180, // Explicit height for grid consistency
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (ws.imageUrl != null)
              Positioned.fill(
                child: SmartImage(
                  imageUrl: ws.imageUrl!,
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                      Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                      Colors.black.withValues(alpha: isDark ? 0.85 : 0.5),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            ws.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showWorkspaceMenu(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.more_horiz, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      ws.description,
                      style: TextStyle(height: 1.2, fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _buildMiniAvatarStack(members),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3525CD),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: const Text(
                            'VIEW DETAILS',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.white, letterSpacing: 0.5)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniAvatarStack(List<User> members) {
    if (members.isEmpty) return const SizedBox.shrink();
    
    final displayMembers = members.take(3).toList();
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: List.generate(displayMembers.length, (i) => Positioned(
          left: i * 14.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 10,
              backgroundImage: displayMembers[i].avatarUrl != null ? NetworkImage(displayMembers[i].avatarUrl!) : null,
              child: displayMembers[i].avatarUrl == null ? const Icon(Icons.person, size: 10) : null,
            ),
          ),
        )),
      ),
    );
  }
}
