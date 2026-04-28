import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/models/workspace.dart';
import '../../../../shared/models/milestone.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/workspace_card.dart';
import '../widgets/milestone_card.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Expanded Curated Mock Data with stylish patterns and live images
    final workspaces = [
      Workspace(
        id: '1', 
        name: 'Design Team', 
        description: 'Creating the next generation of Orbit interfaces.',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80',
      ),
      Workspace(
        id: '2', 
        name: 'Engineering', 
        description: 'Scaling the core infrastructure and sync.',
        imageUrl: 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=500&q=80',
      ),
      Workspace(
        id: '3', 
        name: 'Marketing', 
        description: 'Growth strategies and global campaigns.',
        imageUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?w=500&q=80',
      ),
      Workspace(
        id: '4', 
        name: 'Product Lab', 
        description: 'R&D for future productivity features.',
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&q=80',
      ),
      Workspace(
        id: '5', 
        name: 'Creative Studio', 
        description: 'Art direction and motion graphics.',
        imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=500&q=80',
      ),
      Workspace(
        id: '6', 
        name: 'Human Resources', 
        description: 'Talent acquisition and culture.',
        imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=500&q=80',
      ),
      Workspace(
        id: '7', 
        name: 'Sales Force', 
        description: 'Global outreach and client success.',
        imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&q=80',
      ),
      Workspace(
        id: '8', 
        name: 'Security Vault', 
        description: 'Data protection and terminal security.',
        imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&q=80',
      ),
      Workspace(
        id: '9', 
        name: 'Analytics Lab', 
        description: 'Data-driven insights and forecasting.',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500&q=80',
      ),
    ];

    final milestones = [
      Milestone(
        id: '1',
        projectId: 'p1',
        name: 'V1.0 Launch',
        description: 'Main product launch for early adopters.',
        progress: 0.75,
        totalTasks: 12,
        completedTasks: 9,
      ),
    ];

    final tasks = [
      Task(
        id: 't1',
        milestoneId: '1',
        title: 'Review UI components',
        description: 'Verify all glassmorphic components for consistency.',
        priority: TaskPriority.high,
      ),
    ];

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return ResponsiveScaffold(
      title: 'My Dashboard',
      actions: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xs),
          borderRadius: AppRadius.md,
          blur: 10,
          child: IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: isMobile ? kToolbarHeight + 40 : AppSpacing.md,
          bottom: 120, // Increased to clear floating FAB/BottomNav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardStats(),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(theme, 'Active Workspaces', '${workspaces.length} total'),
            const SizedBox(height: AppSpacing.md),
            
            isMobile 
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    scrollDirection: Axis.horizontal,
                    itemCount: workspaces.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return WorkspaceCard(ws: workspaces[index], isDark: isDark);
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamically calculate columns based on width
                      int crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                      final spacing = AppSpacing.md;
                      final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                      
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: workspaces.map((ws) => WorkspaceCard(
                          ws: ws, 
                          isDark: isDark, 
                          width: itemWidth,
                        )).toList(),
                      );
                    },
                  ),
                ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(theme, 'Priority Milestones', 'Coming soon'),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: milestones.map((m) => MilestoneCard(milestone: m)).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(theme, 'Recent Activity', 'View all'),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: tasks.map((t) => TaskCard(task: t)).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
