import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/widgets/glass_card.dart';

class WorkspaceDetailsScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailsScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailsScreen> createState() => _WorkspaceDetailsScreenState();
}

class _WorkspaceDetailsScreenState extends State<WorkspaceDetailsScreen> {
  String? selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Data
    final projects = [
      Project(
        id: 'p1', 
        workspaceId: widget.workspace.id, 
        name: 'Orbit Mobile', 
        description: 'Primary Flutter application for iOS and Android platforms.'
      ),
      Project(
        id: 'p2', 
        workspaceId: widget.workspace.id, 
        name: 'Web Suite', 
        description: 'Centralized admin dashboard and customer support portal.'
      ),
    ];

    final allMilestones = [
      Milestone(
        id: 'm1',
        projectId: 'p1',
        name: 'Core UI 2.0',
        description: 'Implementing the new glassmorphic design system across all screens.',
        progress: 0.65,
        totalTasks: 24,
        completedTasks: 16,
      ),
      Milestone(
        id: 'm2',
        projectId: 'p1',
        name: 'Backend Sync',
        description: 'Establishing real-time synchronization with Supabase and PowerSync.',
        progress: 0.3,
        totalTasks: 15,
        completedTasks: 5,
      ),
      Milestone(
        id: 'm3',
        projectId: 'p2',
        name: 'Data Viz',
        description: 'Interactive charts and analytics for the web dashboard.',
        progress: 0.85,
        totalTasks: 10,
        completedTasks: 8,
      ),
    ];

    final filteredMilestones = selectedProjectId == null 
        ? allMilestones 
        : allMilestones.where((m) => m.projectId == selectedProjectId).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.2,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.03),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppRadius.lg,
                    blur: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    widget.workspace.name, 
                    style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.workspace.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, 'Active Projects'),
                    const SizedBox(height: AppSpacing.md),
                    _buildProjectsGrid(projects, theme),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, 'Project Milestones'),
                    const SizedBox(height: AppSpacing.md),
                    if (filteredMilestones.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildMilestonesGrid(filteredMilestones, theme),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildProjectsGrid(List<Project> projects, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Drastically increase column count on wide screens to keep cards small
        int crossAxisCount = constraints.maxWidth > 1600 ? 7 : (constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 4 : 2));
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4, // Shorter cards
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final isSelected = selectedProjectId == project.id;
            final isDark = theme.brightness == Brightness.dark;

            // Define vibrant gradients
            final gradients = [
              [const Color(0xFF6366F1), const Color(0xFFA855F7)], 
              [const Color(0xFF3B82F6), const Color(0xFF2DD4BF)], 
              [const Color(0xFFF59E0B), const Color(0xFFEF4444)], 
              [const Color(0xFF10B981), const Color(0xFF3B82F6)], 
            ];
            final projectGradient = gradients[index % gradients.length];

            return GestureDetector(
              onTap: () => setState(() => selectedProjectId = isSelected ? null : project.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isSelected 
                        ? projectGradient[0] 
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? projectGradient[0].withValues(alpha: 0.2) 
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: isSelected ? 15 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Glassy Accent
                    Positioned(
                      top: -15,
                      right: -15,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              projectGradient[0].withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: projectGradient),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded, 
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const Spacer(),
                            Text(
                              project.name, 
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16, // Increased from 13
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.description,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 12, // Increased from 10
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
            );
          },
        );
      },
    );
  }

  Widget _buildMilestonesGrid(List<Milestone> milestones, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Drastically increase columns on large screens to keep cards compact
        int crossAxisCount = constraints.maxWidth > 1600 ? 5 : (constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1));
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5, // Shorter, more horizontal cards
          ),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final isDark = theme.brightness == Brightness.dark;

            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/milestone-details', arguments: milestone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.flag_rounded, color: theme.colorScheme.primary, size: 14),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            milestone.name, 
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16, // Increased from 14
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(milestone.progress * 100).toInt()}%', 
                          style: TextStyle(
                            fontSize: 16, // Increased from 14
                            fontWeight: FontWeight.w900, 
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      milestone.description, 
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12, // Increased from 10
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6, // Slightly thicker for visibility
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: milestone.progress,
                          child: Container(
                            height: 6, // Slightly thicker
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${milestone.completedTasks}/${milestone.totalTasks} Tasks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11, // Increased from 9
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text('Select a project to view milestones', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
