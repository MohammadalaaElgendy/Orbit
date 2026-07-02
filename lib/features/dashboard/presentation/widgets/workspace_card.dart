import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:orbit/core/constants/app_constants.dart';
import 'package:orbit/shared/models/workspace.dart';
import 'package:orbit/shared/models/user.dart';
import 'package:orbit/features/workspace/presentation/widgets/workspace_menu_sheet.dart';
import 'package:orbit/shared/widgets/smart_image.dart';
import 'package:orbit/shared/widgets/orbit_avatar.dart';
import '../view_models/dashboard_view_model.dart';
import '../../../../l10n/app_localizations.dart';

class WorkspaceCard extends StatelessWidget {
  final Workspace ws;
  final bool isDark;
  final double? width;

  const WorkspaceCard({
    super.key,
    required this.ws,
    required this.isDark,
    this.width,
  });

  void _showWorkspaceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkspaceMenuSheet(workspace: ws),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Reactively watch for members of this workspace
    final members = context.select<DashboardViewModel, List<User>>(
      (vm) => vm.workspaceMembersMap[ws.id] ?? []
    );
    
    // Check if current user is admin in this workspace
    bool isAdmin = false;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      try {
        final currentMember = members.firstWhere((m) => m.id == currentUserId);
        isAdmin = currentMember.role == 'admin' || ws.ownerId == currentUserId;
      } catch (_) {
        // Fallback to owner check if not in members list yet
        isAdmin = ws.ownerId == currentUserId;
      }
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/workspace-details', arguments: ws),
      onLongPress: isAdmin ? () => _showWorkspaceMenu(context) : null,
      child: Container(
        width: width ?? 260,
        height: 180, // Explicit height for grid consistency
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), // Reduced from 0.3 / 0.05
              blurRadius: 12, // Reduced from 15
              offset: const Offset(0, 6), // Reduced from 8
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
                        if (isAdmin)
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
                        _buildMiniAvatarStack(members, theme),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Text(
                            l10n.viewDetails.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.white, letterSpacing: 0.5)
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

  Widget _buildMiniAvatarStack(List<User> members, ThemeData theme) {
    if (members.isEmpty) return const SizedBox.shrink();
    
    final displayMembers = members.take(3).toList();
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: List.generate(displayMembers.length, (i) => PositionedDirectional(
          start: i * 14.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: OrbitAvatar(
              radius: 10,
              imageUrl: displayMembers[i].avatarUrl,
            ),
          ),
        )),
      ),
    );
  }
}
