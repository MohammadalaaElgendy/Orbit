import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';

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
                child: Image.network(
                  ws.imageUrl!,
                  fit: BoxFit.cover,
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
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.more_horiz, size: 18, color: Colors.white),
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
                        _buildMiniAvatarStack(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3525CD),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: const Text(
                            '8 PROJECTS', 
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

  Widget _buildMiniAvatarStack() {
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: List.generate(3, (i) => Positioned(
          left: i * 14.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user$i'),
            ),
          ),
        )),
      ),
    );
  }
}
