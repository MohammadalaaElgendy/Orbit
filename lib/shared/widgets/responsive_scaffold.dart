import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart';
import 'orbit_logo.dart';
import 'glass_card.dart';
import '../../core/constants/app_constants.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;
  final Function(int)? onTabSelected;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  void _showUserMenu(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GlassCard(
          borderRadius: AppRadius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(authViewModel.user?.name ?? 'User'),
              subtitle: Text(authViewModel.user?.email ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 600 && size.width < 1024;

    if (isDesktop || isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _buildSideNavigation(theme, isDesktop),
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
    final appBarHeight = kToolbarHeight + topPadding;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: _buildCustomGlassAppBar(theme, topPadding),
      ),
      body: widget.body,
      bottomNavigationBar: _buildFloatingGlassBottomNav(theme),
    );
  }

  Widget _buildCustomGlassAppBar(ThemeData theme, double topPadding) {
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark 
        ? Colors.white.withValues(alpha: 0.15) 
        : Colors.white.withValues(alpha: 0.3);
    
    final user = context.watch<AuthViewModel>().user;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, topPadding, AppSpacing.md, 0),
            height: kToolbarHeight + topPadding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xxl),
                bottomRight: Radius.circular(AppRadius.xxl),
              ),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                // Actions & Avatar
                if (widget.actions != null) 
                  ...widget.actions!.map((action) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                    child: action,
                  )),
                
                // Avatar at the very end
                GestureDetector(
                  onTap: () => _showUserMenu(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: user?.avatarUrl != null 
                          ? NetworkImage(user!.avatarUrl!) 
                          : const NetworkImage('https://i.pravatar.cc/150?u=orbit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingGlassBottomNav(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bgColor = isDark 
        ? Colors.white.withValues(alpha: 0.15) 
        : Colors.white.withValues(alpha: 0.3);

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, bottomPadding > 0 ? bottomPadding : AppSpacing.md),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
                  width: 1.0,
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: widget.currentIndex,
                onTap: widget.onTabSelected,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 26), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.work_rounded, size: 26), label: 'Work'),
                  BottomNavigationBarItem(icon: Icon(Icons.flag_rounded, size: 26), label: 'Goals'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideNavigation(ThemeData theme, bool isDesktop) {
    final user = context.watch<AuthViewModel>().user;
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
              : const Center(child: OrbitLogo(size: 38)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, isDesktop),
          _buildNavItem(Icons.work_rounded, 'Workspaces', 1, isDesktop),
          _buildNavItem(Icons.flag_rounded, 'Milestones', 2, isDesktop),
          const Spacer(),
          if (isDesktop)
            InkWell(
              onTap: () => _showUserMenu(context),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                borderRadius: AppRadius.xl,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: user?.avatarUrl != null 
                          ? NetworkImage(user!.avatarUrl!) 
                          : const NetworkImage('https://i.pravatar.cc/150?u=orbit'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Text('Pro Member', style: TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.settings, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _showUserMenu(context),
              child: CircleAvatar(
                radius: 20, 
                backgroundImage: user?.avatarUrl != null 
                    ? NetworkImage(user!.avatarUrl!) 
                    : const NetworkImage('https://i.pravatar.cc/150?u=orbit'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDesktop) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => widget.onTabSelected?.call(index),
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
          if (widget.actions != null) 
            ...widget.actions!.map((action) => Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: action,
            )),
        ],
      ),
    );
  }
}
