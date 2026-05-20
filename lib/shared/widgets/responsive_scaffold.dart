import 'dart:ui';
import 'package:flutter/material.dart';
import 'orbit_logo.dart';
import 'glass_card.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

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
  void _showAvatarOptions(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.xxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(authViewModel.user?.avatarUrl == null ? 'Add Photo' : 'Change Photo'),
              onTap: () {
                Navigator.pop(context);
                authViewModel.updateProfileAvatar();
              },
            ),
            if (authViewModel.user?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  authViewModel.deleteProfileAvatar();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.user;
          final isLoading = authViewModel.isLoading;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                          onBackgroundImageError: user?.avatarUrl != null ? (e, s) => debugPrint("Load error") : null,
                          child: user?.avatarUrl == null ? Icon(Icons.person, size: 30, color: theme.colorScheme.primary) : null,
                        ),
                      ),
                      if (isLoading)
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      if (!isLoading)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: GestureDetector(
                            onTap: () => _showAvatarOptions(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                              ),
                              child: const Icon(Icons.edit, size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.name ?? 'User',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  IgnorePointer(
                    ignoring: isLoading,
                    child: Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -4),
                            leading: const Icon(Icons.person_outlined, size: 20),
                            title: const Text('Profile Settings', style: TextStyle(fontSize: 13)),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -4),
                            leading: const Icon(Icons.palette, size: 20),
                            title: const Text('Appearance', style: TextStyle(fontSize: 13)),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -4),
                            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                            onTap: () async {
                              final nav = Navigator.of(context);
                              await authViewModel.logout();
                              nav.pushNamedAndRemoveUntil('/welcome', (route) => false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xs),
                ],
              ),
            ),
          );
        },
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
                if (widget.actions != null) 
                  ...widget.actions!.map((action) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                    child: action,
                  )),
                
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
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: context.watch<AuthViewModel>().user?.avatarUrl != null
                          ? NetworkImage(context.watch<AuthViewModel>().user!.avatarUrl!)
                          : null,
                      onBackgroundImageError: context.watch<AuthViewModel>().user?.avatarUrl != null ? (e, s) => debugPrint("Load error") : null,
                      child: context.watch<AuthViewModel>().user?.avatarUrl == null
                          ? Icon(Icons.person, size: 16, color: theme.colorScheme.primary)
                          : null,
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
            GestureDetector(
              onTap: () => _showUserMenu(context),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                borderRadius: AppRadius.xl,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: context.watch<AuthViewModel>().user?.avatarUrl != null
                          ? NetworkImage(context.watch<AuthViewModel>().user!.avatarUrl!)
                          : null,
                      onBackgroundImageError: context.watch<AuthViewModel>().user?.avatarUrl != null ? (e, s) => debugPrint("Load error") : null,
                      child: context.watch<AuthViewModel>().user?.avatarUrl == null
                          ? Icon(Icons.person, size: 18, color: theme.colorScheme.primary)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.watch<AuthViewModel>().user?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: context.watch<AuthViewModel>().user?.avatarUrl != null
                    ? NetworkImage(context.watch<AuthViewModel>().user!.avatarUrl!)
                    : null,
                onBackgroundImageError: context.watch<AuthViewModel>().user?.avatarUrl != null ? (e, s) => debugPrint("Load error") : null,
                child: context.watch<AuthViewModel>().user?.avatarUrl == null
                    ? Icon(Icons.person, size: 20, color: theme.colorScheme.primary)
                    : null,
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
