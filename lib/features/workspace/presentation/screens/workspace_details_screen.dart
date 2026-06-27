import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass/glass.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/milestone.dart' as model;
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../view_models/workspace_view_model.dart';
import '../widgets/project_dialog.dart';
import '../widgets/member_search_dialog.dart';
import '../widgets/member_details_dialog.dart';
import '../widgets/workspace_menu_sheet.dart';
import '../widgets/project_card.dart';
import '../../../milestone/presentation/view_models/milestone_view_model.dart';
import '../../../milestone/presentation/widgets/milestone_dialog.dart';
import '../../../dashboard/presentation/widgets/milestone_card.dart';
import 'dart:async';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../shared/widgets/top_padding.dart';
import '../../../../shared/widgets/orbit_avatar.dart';
import '../../../../l10n/app_localizations.dart';

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
            context.read<WorkspaceViewModel>().updateProject(project.copyWith(
              name: name,
              description: desc,
              color: color,
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
          context.read<MilestoneViewModel>().createMilestone(context, selectedProjectId!, name, desc, dueDate);
        },
      ),
    );
  }

  void _showWorkspaceMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => WorkspaceMenuSheet(
        workspace: widget.workspace,
        onDelete: () => Navigator.pop(context),
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
    final viewModel = context.watch<WorkspaceViewModel>();
    final currentWorkspace = viewModel.currentWorkspace ?? widget.workspace;
    final projects = viewModel.projects;
    final members = viewModel.members;
    final l10n = AppLocalizations.of(context)!;

    // تثبيت عناصر شريط الإشعارات على اللون الأبيض الناصع (أندرويد + آيفون)
    final overlayStyle = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // أيقونات بيضاء للأندرويد
      statusBarBrightness: Brightness.dark, // أيقونات بيضاء للآيفون
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: true,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                systemOverlayStyle: overlayStyle, // فرض اللون الأبيض هنا أيضاً
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppRadius.lg,
                    blur: 10,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (viewModel.isAdmin)
                   Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: AppRadius.lg,
                      blur: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showWorkspaceMenu,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.more_vert_rounded, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Builder(
                    builder: (context) {
                      final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                      if (settings == null) return const SizedBox.shrink();

                      final double deltaExtent = settings.maxExtent - settings.minExtent;
                      final double ratio = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);
                      // ratio: 0.0 = expanded, 1.0 = collapsed

                      final isMobile = MediaQuery.of(context).size.width < 600;

                      // Fix: Stay white longer, then transition to theme color when almost collapsed
                      final Color titleColor = ratio > 0.8
                          ? Color.lerp(Colors.white, theme.colorScheme.onSurface, (ratio - 0.8) * 5)!
                          : Colors.white;

                      // Vertical centering adjustment for collapsed state
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
                              start: isMobile ? 0 : (440.0 * (1.0 - ratio)),
                              bottom: isMobile ? 0 : (AppSpacing.lg * (1.0 - ratio)),
                            ),
                            child: Text(
                              currentWorkspace.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: (0.35 * (1.0 - ratio)).clamp(0.0, 1.0)),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1.5),
                                  ),
                                  Shadow(
                                    color: Colors.black.withValues(alpha: (0.2 * (1.0 - ratio)).clamp(0.0, 1.0)),
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
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

                      final radius = AppRadius.xxl * (1.0 - ratio);
                      return ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(radius),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                        children: [
                          if (currentWorkspace.imageUrl != null)
                            SmartImage(
                              imageUrl: currentWorkspace.imageUrl!,
                            ),

                          // شادو علوي قوي لضمان رؤية أيقونات الساعة والبطارية البيضاء
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.4],
                                ),
                              ),
                            ),
                          ),

                          // Always blur background on large screens to hide pixelation
                          if (!isMobile)
                            Container(
                              color: Colors.black.withValues(alpha: 0.2),
                            ).asGlass(
                              blurX: 0,
                              blurY: 0,
                              tileMode: TileMode.clamp,
                            ),

                          // Blur effect layer
                          if (!isMobile)
                            Container(color: Colors.transparent).asGlass(
                              blurX: 15.0,
                              blurY: 15.0,
                              frosted: false
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
                      ),
                    );
                    }
                  ),
                ),
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverPadding(
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
                    _buildSectionHeader(theme, l10n.members, onAdd: viewModel.isAdmin ? _showMemberSearchDialog : null),
                    const SizedBox(height: AppSpacing.md),
                    _buildMembersList(members, theme, l10n, viewModel.isAdmin),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, l10n.activeProjects, onAdd: viewModel.isAdmin ? () => _showProjectDialog() : null),
                    const SizedBox(height: AppSpacing.md),
                    projects.isEmpty
                      ? _buildEmptyProjects(theme, l10n, viewModel.isAdmin)
                      : _buildProjectsGrid(projects, theme),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(theme, l10n.projectMilestones, onAdd: (viewModel.isAdmin && selectedProjectId != null) ? _showMilestoneDialog : null),
                    const SizedBox(height: AppSpacing.md),
                    if (_milestones.isEmpty)
                      _buildEmptyMilestones(theme, l10n, viewModel.isAdmin)
                    else
                      _buildMilestonesGrid(_milestones, theme),
                    const BottomPadding(),
                  ]),
                ),
              ),
              ),
            ],
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

  Widget _buildMembersList(List<User> members, ThemeData theme, AppLocalizations l10n, bool isAdmin) {
    if (members.isEmpty) return Text(l10n.noMembers);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final member = members[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => MemberDetailsDialog(user: member),
              );
            },
            onLongPress: isAdmin ? () {
               showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: l10n.removeMember,
                  message: l10n.removeMemberConfirm(member.name),
                  confirmLabel: l10n.remove,
                  confirmColor: Colors.red,
                  onConfirm: () => context.read<WorkspaceViewModel>().removeMember(widget.workspace.id, member.id),
                ),
              );
            } : null,
            child: OrbitAvatar(
              radius: 20,
              imageUrl: member.avatarUrl,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsGrid(List<Project> projects, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidth = 160.0;
        const double maxWidth = 240.0; // Added max width constraint
        const double spacing = AppSpacing.md;
        
        int crossAxisCount = (constraints.maxWidth / (minWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, projects.isNotEmpty ? projects.length : 1);
        
        double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        
        // Ensure the width doesn't exceed maxWidth
        if (itemWidth > maxWidth) {
          itemWidth = maxWidth;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: projects.map((project) {
            final isSelected = selectedProjectId == project.id;
            return ProjectCard(
              project: project,
              isSelected: isSelected,
              onTap: () => _onProjectSelected(isSelected ? null : project.id),
              width: itemWidth,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyProjects(ThemeData theme, AppLocalizations l10n, bool isAdmin) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.noProjects),
          if (isAdmin)
            TextButton(onPressed: () => _showProjectDialog(), child: Text(l10n.addProject)),
        ],
      ),
    );
  }

  Widget _buildEmptyMilestones(ThemeData theme, AppLocalizations l10n, bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text(selectedProjectId == null ? l10n.selectProjectToViewMilestones : l10n.noMilestonesForProject),
            if (isAdmin && selectedProjectId != null)
              TextButton(onPressed: _showMilestoneDialog, child: Text(l10n.addMilestone)),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesGrid(List<model.Milestone> milestones, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidth = 280.0;
        const double maxWidth = 400.0;
        const double spacing = AppSpacing.md;
        
        int crossAxisCount = (constraints.maxWidth / (minWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, milestones.isNotEmpty ? milestones.length : 1);
        
        double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        itemWidth = itemWidth.clamp(minWidth, maxWidth);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: milestones.map((milestone) {
            return SizedBox(
              width: itemWidth,
              child: MilestoneCard(milestone: milestone),
            );
          }).toList(),
        );
      },
    );
  }
}
