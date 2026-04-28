import 'package:flutter/material.dart';
import 'orbit_logo.dart';
import 'glass_card.dart';
import '../../core/constants/app_constants.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 600 && size.width < 1024;

    if (isDesktop || isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Side Navigation Panel
            _buildSideNavigation(theme, isDesktop),
            
            // Main Content Area
            Expanded(
              child: Container(
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
                child: Column(
                  children: [
                    // Desktop/Tablet Header
                    _buildTopHeader(theme),
                    Expanded(child: widget.body),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile View
    return Scaffold(
      extendBody: true, // Content behind floating bottom bar
      extendBodyBehindAppBar: true, // Content behind app bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: _buildCustomGlassAppBar(theme),
      ),
      body: widget.body,
      bottomNavigationBar: _buildFloatingGlassBottomNav(theme),
    );
  }

  Widget _buildCustomGlassAppBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 0, // We handle rounding manually below
        blur: 20,
        opacity: isDark ? 0.05 : 0.1,
        borderColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            // Specific Geometry: Sharp top, Rounded bottom
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xxl),
              bottomRight: Radius.circular(AppRadius.xxl),
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight + 10,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    widget.title, 
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    )
                  ),
                  const Spacer(),
                  ...widget.actions?.map((action) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: action,
                  )).toList() ?? [],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingGlassBottomNav(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.xxl,
        blur: 25,
        opacity: isDark ? 0.05 : 0.1,
        borderColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.3),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 26), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work_rounded, size: 26), label: 'Work'),
            BottomNavigationBarItem(icon: Icon(Icons.flag_rounded, size: 26), label: 'Goals'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 26), label: 'Me'),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNavigation(ThemeData theme, bool isDesktop) {
    return Container(
      width: isDesktop ? 280 : 80,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? AppSpacing.md : 0),
            child: isDesktop 
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const OrbitLogo(size: 38),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Text(
                        'Orbit', 
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: OrbitLogo(size: 38),
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, isDesktop),
          _buildNavItem(Icons.work_rounded, 'Workspaces', 1, isDesktop),
          _buildNavItem(Icons.flag_rounded, 'Milestones', 2, isDesktop),
          _buildNavItem(Icons.check_circle_rounded, 'Tasks', 3, isDesktop),
          const Spacer(),
          if (isDesktop)
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              borderRadius: AppRadius.xl,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=orbit'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mohammad', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Pro Member', 
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.settings, size: 16, color: Colors.grey),
                ],
              ),
            )
          else
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=orbit'),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDesktop) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: isDesktop ? AppSpacing.md : 0),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
              if (isDesktop) ...[
                const SizedBox(width: AppSpacing.md),
                Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const Spacer(),
          ...widget.actions ?? [],
        ],
      ),
    );
  }
}
