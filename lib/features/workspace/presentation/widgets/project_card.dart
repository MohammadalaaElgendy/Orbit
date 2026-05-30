import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/project.dart';
import 'project_menu_sheet.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final projectColor = project.color != null 
        ? Color(int.parse(project.color!.replaceAll('#', '0xFF'))) 
        : theme.colorScheme.primary;

    final projectGradient = [
      projectColor.withValues(alpha: 0.8),
      projectColor,
    ];

    final radius = AppRadius.xl;
    
    // Smoothly interpolate border color and width
    final Color currentBorderColor = isSelected 
        ? projectColor 
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05));
    
    final double currentBorderWidth = isSelected ? 2.0 : 1.2;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: width,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? projectColor.withValues(alpha: 0.25) 
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              // Glass Background + Border Integrated
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.03) 
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: currentBorderColor,
                      width: currentBorderWidth,
                    ),
                  ),
                ).asGlass(
                  blurX: 15,
                  blurY: 15,
                  clipBorderRadius: BorderRadius.circular(radius),
                ),
              ),

              // Decorative background glow
              PositionedDirectional(
                top: -20,
                end: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        projectColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: projectGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: projectColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded, 
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          onPressed: () => _showMenu(context),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      project.name, 
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900, 
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ProjectMenuSheet(project: project),
    );
  }
}
