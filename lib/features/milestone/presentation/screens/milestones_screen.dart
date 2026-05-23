import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/presentation/widgets/milestone_card.dart';
import 'package:orbit/shared/widgets/top_padding.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../../../shared/models/milestone.dart';

enum MilestoneSort { progressAsc, progressDesc, deadlineAsc, deadlineDesc }

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  MilestoneSort _currentSort = MilestoneSort.deadlineAsc;
  late Stream<List<Milestone>> _milestonesStream;

  @override
  void initState() {
    super.initState();
    // تعريف الـ Stream مرة واحدة فقط عند فتح الشاشة لمنع الرعشة
    _milestonesStream = context.read<MilestoneRepository>().watchAllMilestones();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Milestone>>(
      stream: _milestonesStream,
      builder: (context, snapshot) {
        // لا تظهر علامة التحميل إلا في المرة الأولى فقط
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // استخدام نسخة من البيانات للفرز
        List<Milestone> milestones = List.from(snapshot.data ?? []);
        _sortMilestones(milestones);

        if (milestones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'No milestones found.\nBreak down your projects into goals!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        // Group milestones by workspace name
        final Map<String, List<Milestone>> grouped = {};
        for (var m in milestones) {
          final wsName = m.workspaceName ?? 'General';
          grouped.putIfAbsent(wsName, () => []).add(m);
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: TopPadding()),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(
                      'Sort by:',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip('Deadline', MilestoneSort.deadlineAsc, MilestoneSort.deadlineDesc),
                    const SizedBox(width: 8),
                    _buildSortChip('Progress', MilestoneSort.progressAsc, MilestoneSort.progressDesc),
                  ],
                ),
              ),
            ),

            ...grouped.entries.map((entry) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.value.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final m = entry.value[index];
                          // Removed Center and ConstrainedBox to let the card fill the width
                          return MilestoneCard(milestone: m);
                        },
                        childCount: entry.value.length,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SliverToBoxAdapter(child: BottomPadding()),
          ],
        );
      },
    );
  }

  Widget _buildSortChip(String label, MilestoneSort asc, MilestoneSort desc) {
    final theme = Theme.of(context);
    final isSelected = _currentSort == asc || _currentSort == desc;
    final isAsc = _currentSort == asc;
    const accentColor = Color(0xFF3525CD); // المرجعي من كارت المساحة

    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              isAsc ? Icons.arrow_upward : Icons.arrow_downward, 
              size: 14, 
              color: isSelected ? Colors.white : null,
            ),
          ],
        ],
      ),
      onPressed: () {
        setState(() {
          if (_currentSort == asc) {
            _currentSort = desc;
          } else {
            _currentSort = asc;
          }
        });
      },
      backgroundColor: isSelected ? accentColor : (theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isSelected ? accentColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _sortMilestones(List<Milestone> milestones) {
    switch (_currentSort) {
      case MilestoneSort.progressAsc:
        milestones.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case MilestoneSort.progressDesc:
        milestones.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case MilestoneSort.deadlineAsc:
        milestones.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case MilestoneSort.deadlineDesc:
        milestones.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return b.dueDate!.compareTo(a.dueDate!);
        });
        break;
    }
  }
}
