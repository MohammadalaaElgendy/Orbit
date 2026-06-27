import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'orbit_logo.dart';
import 'glass_card.dart';
import '../../core/constants/app_constants.dart';
import 'orbit_avatar.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart';
import '../../features/auth/presentation/widgets/user_profile_sheet.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

class ResponsiveScaffold extends StatefulWidget {
// ... (rest of class)
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => const UserProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // ستايل افتراضي يتبع الثيم (أيقونات سوداء في الوضع الفاتح، وبيضاء في الداكن)
    final systemOverlayStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 600 && size.width < 1024;

    Widget content;
    if (isDesktop || isTablet) {
      content = Scaffold(
        body: Row(
          children: [
            _buildSideNavigation(theme, isDesktop, l10n),
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
    } else {
      // Mobile View
      final appBarExtraPadding = AppSpacing.sm;
      final appBarHeight = kToolbarHeight + topPadding + appBarExtraPadding;
      content = Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: _buildCustomGlassAppBar(theme, topPadding, appBarExtraPadding),
        ),
        body: widget.body,
        bottomNavigationBar: _buildFloatingGlassBottomNav(theme, l10n),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: content,
    );
  }

  Widget _buildCustomGlassAppBar(ThemeData theme, double topPadding, double extraPadding) {
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark 
        ? theme.colorScheme.surface.withValues(alpha: 0.6) 
        : Colors.white.withValues(alpha: 0.7);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, topPadding + extraPadding, AppSpacing.md, extraPadding),
        height: kToolbarHeight + topPadding + extraPadding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.xxl),
            bottomRight: Radius.circular(AppRadius.xxl),
          ),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.title, 
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
                child: OrbitAvatar(
                  radius: 16,
                  imageUrl: context.watch<AuthViewModel>().user?.avatarUrl,
                ),
              ),
            ),
          ],
        ),
      ).asGlass(
        blurX: 15,
        blurY: 15,
        clipBorderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
      ),
    );
  }

  Widget _buildFloatingGlassBottomNav(ThemeData theme, AppLocalizations l10n) {
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
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded, size: 26), label: l10n.home),
              BottomNavigationBarItem(icon: const Icon(Icons.work_rounded, size: 26), label: l10n.work),
              BottomNavigationBarItem(icon: const Icon(Icons.flag_rounded, size: 26), label: l10n.goals),
            ],
          ),
        ).asGlass(
          blurX: 25,
          blurY: 25,
          clipBorderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
    );
  }

  Widget _buildSideNavigation(ThemeData theme, bool isDesktop, AppLocalizations l10n) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      width: isDesktop ? 280 : 80,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md, 
                    AppSpacing.xl + topPadding, 
                    AppSpacing.md, 
                    AppSpacing.xl + bottomPadding
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
                      _buildNavItem(Icons.dashboard_rounded, l10n.home, 0, isDesktop),
                      _buildNavItem(Icons.work_rounded, l10n.work, 1, isDesktop),
                      _buildNavItem(Icons.flag_rounded, l10n.goals, 2, isDesktop),
                      const Spacer(),
                      if (isDesktop)
                        GestureDetector(
                          onTap: () => _showUserMenu(context),
                          child: GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            borderRadius: AppRadius.xl,
                            child: Row(
                              children: [
                                OrbitAvatar(
                                  radius: 18,
                                  imageUrl: context.watch<AuthViewModel>().user?.avatarUrl,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(context.watch<AuthViewModel>().user?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(context.watch<AuthViewModel>().user?.email ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          child: OrbitAvatar(
                            radius: 20,
                            imageUrl: context.watch<AuthViewModel>().user?.avatarUrl,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg + topPadding, AppSpacing.lg, AppSpacing.lg),
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
