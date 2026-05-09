import 'package:flutter/material.dart';
import 'package:orbit/shared/widgets/responsive_scaffold.dart';
import 'dashboard_screen.dart';
import 'package:orbit/features/workspace/presentation/screens/workspaces_screen.dart';
import 'package:orbit/features/milestone/presentation/screens/milestones_screen.dart';
import 'package:orbit/features/workspace/presentation/widgets/workspace_dialog.dart';
import 'package:provider/provider.dart';
import '../view_models/dashboard_view_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/constants/app_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _showCreateWorkspace(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WorkspaceDialog(
        onSave: (name, desc, imageUrl, memberIds) => context.read<DashboardViewModel>().createWorkspace(name, desc, imageUrl, memberIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onTabSelected: (index) => setState(() => _currentIndex = index),
      title: _getTitle(),
      actions: _getActions(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardScreen(isTab: true),
          const WorkspacesScreen(),
          const MilestonesScreen(),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'My Dashboard';
      case 1: return 'Workspaces';
      case 2: return 'Milestones';
      case 3: return 'My Profile';
      default: return 'Orbit';
    }
  }

  List<Widget> _getActions(BuildContext context) {
    if (_currentIndex == 0) {
      return [
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.md,
          blur: 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showCreateWorkspace(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.add_rounded, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.md,
          blur: 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ];
    }
    return [];
  }
}
