import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/milestone.dart' as model;
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../view_models/workspace_view_model.dart';
import '../widgets/project_dialog.dart';
import '../widgets/workspace_dialog.dart';
import '../widgets/member_search_dialog.dart';
import '../../../milestone/presentation/view_models/milestone_view_model.dart';
import '../../../milestone/presentation/widgets/milestone_dialog.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import '../../../../shared/widgets/smart_image.dart';

class WorkspaceDetailsScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailsScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailsScreen> createState() => _WorkspaceDetailsScreenState();
}

class _WorkspaceDetailsScreenState extends State<WorkspaceDetailsScreen> {
  String? selectedProjectId;
  List<model.Milestone> _milestones = [];
  StreamSubscription? _milestoneSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceViewModel>().loadWorkspace(widget.workspace.id);
    });
  }

  @override
  void dispose() {
    _milestoneSub?.cancel();
    super.dispose();
  }

  void _onProjectSelected(String? projectId) {
    setState(() => selectedProjectId = projectId);
    _milestoneSub?.cancel();
    if (projectId != null) {
      _milestoneSub = context.read<MilestoneViewModel>().watchMilestonesByProject(projectId).listen((data) {
        setState(() => _milestones = data);
      });
    } else {
      setState(() => _milestones = []);
    }
  }

  void _showProjectDialog({Project? project}) {
    showDialog(
      context: context,
      builder: (_) => ProjectDialog(
        project: project,
        workspaceId: widget.workspace.id,
        onSave: (name, desc, color) {
          if (project != null) {
            context.read<WorkspaceViewModel>().updateProject(Project(
              id: project.id,
              workspaceId: project.workspaceId,
              name: name,
              description: desc,
              color: color,
              createdAt: project.createdAt,
              updatedAt: DateTime.now(),
            ));
          } else {
            context.read<WorkspaceViewModel>().createProject(widget.workspace.id, name, desc, color);
          }
        },
      ),
    );
  }

  void _showMilestoneDialog() {
    if (selectedProjectId == null) return;
    showDialog(
      context: context,
      builder: (_) => MilestoneDialog(
        projectId: selectedProjectId,
        onSave: (name, desc, dueDate) {
          context.read<MilestoneViewModel>().createMilestone(selectedProjectId!, name, desc, dueDate);
        },
      ),
    );
  }

  void _showWorkspaceMenu() {
    final viewModel = context.read<WorkspaceViewModel>();
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
              final members = await viewModel.getWorkspaceMembers(widget.workspace.id);
              if (!mounted) return;
              
              showDialog(
                context: context,
                builder: (_) => WorkspaceDialog(
                  workspace: widget.workspace,
                  currentMembers: members,
                  onSave: (name, desc, imageUrl, memberIds) => viewModel.updateWorkspace(widget.workspace.id, name, desc, imageUrl, memberIds),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Workspace', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              viewModel.deleteWorkspace(widget.workspace.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _showMemberSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => MemberSearchDialog(workspaceId: widget.workspace.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<WorkspaceViewModel>();
    final currentWorkspace = viewModel.currentWorkspace ?? widget.workspace;
    final projects = viewModel.projects;
    final members = viewModel.members;

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
                expandedHeight: 200,
                floating: true,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
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
                actions: [
                   Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: AppRadius.lg,
                      blur: 10,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        onPressed: _showWorkspaceMenu,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final top = constraints.biggest.height;
                      final isMobile = MediaQuery.of(context).size.width < 600;
                      
                      // Calculate interpolation ratio (0.0 = expanded, 1.0 = collapsed)
                      final expandedHeight = 200.0 + MediaQuery.of(context).padding.top;
                      final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                      final ratio = ((expandedHeight - top) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

                      final Color titleColor = isDark 
                          ? Colors.white 
                          : Color.lerp(Colors.white, Colors.black, ratio)!;

                      // Vertical centering adjustment for collapsed state (Toolbar vs entire AppBar height)
                      final double verticalOffset = (MediaQuery.of(context).padding.top / 2) * ratio;

                      return Align(
                        alignment: isMobile 
                            ? Alignment.center 
                            : AlignmentDirectional.lerp(
                                AlignmentDirectional.bottomStart, 
                                AlignmentDirectional.center, 
                                ratio
                              )!.resolve(Directionality.of(context)),
                        child: Transform.translate(
                          offset: Offset(0, verticalOffset + 10),
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: isMobile ? 0 : (440.0 * (1.0 - ratio)), // Increased displacement
                              bottom: isMobile ? 0 : (AppSpacing.lg * (1.0 - ratio)),
                            ),
                            child: Text(
                              currentWorkspace.name, 
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 18, 
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                                shadows: ratio < 0.5 || isDark ? [
                                  const Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2)),
                                ] : [],
                              )
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  expandedTitleScale: 1.0,
                  background: LayoutBuilder(
                    builder: (context, constraints) {
                      final top = constraints.biggest.height;
                      final isMobile = MediaQuery.of(context).size.width < 600;
                      final expandedHeight = 200.0 + MediaQuery.of(context).padding.top;
                      final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                      final ratio = ((expandedHeight - top) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (currentWorkspace.imageUrl != null)
                            SmartImage(
                              imageUrl: currentWorkspace.imageUrl!,
                            ),
                          // Always blur background on large screens to hide pixelation
                          if (!isMobile)
                            ClipRect(
                              child: BackdropFilter(
                                filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.darken),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          
                          // Blur effect layer
                          if (!isMobile)
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                                child: Container(color: Colors.transparent),
                              ),
                            ),

                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: isMobile ? 0.7 : 0.4),
                                ],
                              ),
                            ),
                          ),

                          // Clear Image Card for Large Screens
                          if (!isMobile && currentWorkspace.imageUrl != null)
                            PositionedDirectional(
                              start: 100,
                              bottom: AppSpacing.lg,
                              child: Opacity(
                                opacity: (1.0 - (ratio * 1.5)).clamp(0.0, 1.0),
                                child: Container(
                                  width: 240,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      )
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: SmartImage(imageUrl: currentWorkspace.imageUrl!),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      currentWorkspace.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, 'Members', onAdd: _showMemberSearchDialog),
                    const SizedBox(height: AppSpacing.md),
                    _buildMembersList(members, theme),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, 'Active Projects', onAdd: () => _showProjectDialog()),
                    const SizedBox(height: AppSpacing.md),
                    projects.isEmpty 
                      ? _buildEmptyProjects(theme)
                      : _buildProjectsGrid(projects, theme),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, 'Project Milestones', onAdd: selectedProjectId != null ? _showMilestoneDialog : null),
                    const SizedBox(height: AppSpacing.md),
                    if (_milestones.isEmpty)
                      _buildEmptyMilestones(theme)
                    else
                      _buildMilestonesGrid(_milestones, theme),
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

  Widget _buildSectionHeader(ThemeData theme, String title, {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            color: theme.colorScheme.primary,
          ),
      ],
    );
  }

  Widget _buildMembersList(List<User> members, ThemeData theme) {
    if (members.isEmpty) return const Text('No members yet');
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final member = members[index];
          return GestureDetector(
            onLongPress: () {
               showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Member'),
                  content: Text('Are you sure you want to remove ${member.name} from this workspace?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<WorkspaceViewModel>().removeMember(widget.workspace.id, member.id);
                        Navigator.pop(context);
                      }, 
                      child: const Text('Remove', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
              child: member.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsGrid(List<Project> projects, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define constraints for project cards
        const double minWidth = 180.0;
        const double maxWidth = 280.0;
        const double spacing = AppSpacing.md;
        
        // Calculate number of items per row based on available width
        int crossAxisCount = (constraints.maxWidth / (minWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, projects.isNotEmpty ? projects.length : 1);
        
        // Calculate actual width of each item to fill space between min and max
        double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        itemWidth = itemWidth.clamp(minWidth, maxWidth);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: projects.map((project) {
            final isSelected = selectedProjectId == project.id;
            final isDark = theme.brightness == Brightness.dark;
            final projectColor = project.color != null 
                ? Color(int.parse(project.color!.replaceAll('#', '0xFF'))) 
                : theme.colorScheme.primary;

            final projectGradient = [
              projectColor.withValues(alpha: 0.8),
              projectColor,
            ];

            return GestureDetector(
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Edit Project'),
                        onTap: () {
                          Navigator.pop(context);
                          _showProjectDialog(project: project);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        title: const Text('Delete Project', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<WorkspaceViewModel>().deleteProject(project.id);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
              onTap: () => _onProjectSelected(isSelected ? null : project.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: itemWidth,
                height: 140, // Fixed height for consistency
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
                                fontSize: 16,
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
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyProjects(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.sm),
          const Text('No projects yet. Create one to get started!'),
          TextButton(onPressed: () => _showProjectDialog(), child: const Text('Add Project')),
        ],
      ),
    );
  }

  Widget _buildEmptyMilestones(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text(selectedProjectId == null ? 'Select a project to view milestones' : 'No milestones for this project.'),
            if (selectedProjectId != null)
              TextButton(onPressed: _showMilestoneDialog, child: const Text('Add Milestone')),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesGrid(List<model.Milestone> milestones, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define constraints for milestone cards (typically wider than projects)
        const double minWidth = 280.0;
        const double maxWidth = 400.0;
        const double spacing = AppSpacing.md;
        
        // Calculate distribution
        int crossAxisCount = (constraints.maxWidth / (minWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, milestones.isNotEmpty ? milestones.length : 1);
        
        double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        itemWidth = itemWidth.clamp(minWidth, maxWidth);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: milestones.map((milestone) {
            final isDark = theme.brightness == Brightness.dark;

            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/milestone-details', arguments: milestone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: itemWidth,
                height: 180, // Slightly increased for deadline text
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
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(milestone.progress * 100).toInt()}%', 
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900, 
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDeadlineInfo(milestone.dueDate, theme),
                    const Spacer(),
                    Text(
                      milestone.description, 
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12,
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: milestone.progress,
                          child: Container(
                            height: 6,
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
                    const SizedBox(height: 8),
                    Text(
                      '${milestone.completedTasks}/${milestone.totalTasks} Tasks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDeadlineInfo(DateTime? deadline, ThemeData theme) {
    if (deadline == null) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final difference = deadline.difference(now);
    final isOverdue = difference.isNegative;
    final isUrgent = !isOverdue && difference.inDays < 3;
    
    final color = isOverdue ? Colors.red : (isUrgent ? Colors.orange : Colors.green);
    final icon = isOverdue ? Icons.error_outline_rounded : Icons.access_time_rounded;
    
    String text;
    if (isOverdue) {
      text = 'Overdue';
    } else if (difference.inDays > 0) {
      text = '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      text = '${difference.inHours} hours left';
    } else {
      text = 'Due soon';
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('MMM dd').format(deadline),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
