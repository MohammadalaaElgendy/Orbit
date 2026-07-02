import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/auth_view_model.dart';
import 'avatar_options_sheet.dart';
import '../../../../shared/widgets/orbit_avatar.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';

class UserProfileSheet extends StatefulWidget {
  const UserProfileSheet({super.key});

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  bool _showAppearanceOptions = false;

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeModel = context.watch<ThemeModel>();
    final localeModel = context.watch<LocaleModel>();

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;
        final isLoading = authViewModel.isLoading;
        final isLight = theme.brightness == Brightness.light;
        final textShadows = isLight ? [Shadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)] : null;

        return GlassBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                    Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: OrbitAvatar(
                        radius: 35,
                        imageUrl: user?.avatarUrl,
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 35,
                        height: 35,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    if (!isLoading)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarOptions(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  user?.name ?? 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    shadows: textShadows,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                
                _buildListTile(
                  icon: Icons.person_outline,
                  title: l10n.profileSettings,
                  onTap: () {},
                ),

                _buildAppearanceSection(theme, themeModel, l10n),
                
                _buildLanguageSection(theme, localeModel, l10n),

                const Divider(),
                _buildListTile(
                  icon: Icons.logout,
                  title: l10n.logout,
                  color: Colors.redAccent,
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await authViewModel.logout();
                    nav.pushNamedAndRemoveUntil('/welcome', (route) => false);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
              ],
            ),
        );
      },
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textShadows = isLight ? [Shadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)] : null;
    return ListTile(
      leading: Icon(icon, size: 22, color: color ?? theme.colorScheme.onSurface, shadows: textShadows),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color, shadows: textShadows)),
      trailing: Icon(Icons.chevron_right, size: 18, shadows: textShadows),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAppearanceSection(ThemeData theme, ThemeModel themeModel, AppLocalizations l10n) {
    final isLight = theme.brightness == Brightness.light;
    final textShadows = isLight ? [Shadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)] : null;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.palette_outlined, size: 22, shadows: textShadows),
          title: Text(l10n.appearance, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, shadows: textShadows)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              themeModel.mode == ThemeMode.system ? l10n.system : (themeModel.mode == ThemeMode.dark ? l10n.dark : l10n.light),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
          ),
          onTap: () => setState(() => _showAppearanceOptions = !_showAppearanceOptions),
          contentPadding: EdgeInsets.zero,
        ),
        if (_showAppearanceOptions) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton(l10n.light, Icons.light_mode, ThemeMode.light, themeModel),
                _buildModeButton(l10n.dark, Icons.dark_mode, ThemeMode.dark, themeModel),
                _buildModeButton(l10n.system, Icons.settings_brightness, ThemeMode.system, themeModel),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(l10n.colorThemes, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, shadows: textShadows)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ThemePreset.values.map((preset) => _buildThemePresetCircle(preset, themeModel, l10n)).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildModeButton(String label, IconData icon, ThemeMode mode, ThemeModel themeModel) {
    final isSelected = themeModel.mode == mode;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textShadows = isLight ? [Shadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)] : null;
    return GestureDetector(
      onTap: () => themeModel.setMode(mode),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: isSelected ? Colors.white : theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, shadows: textShadows)),
        ],
      ),
    );
  }

  Widget _buildThemePresetCircle(ThemePreset preset, ThemeModel themeModel, AppLocalizations l10n) {
    final isSelected = themeModel.preset == preset;
    final theme = Theme.of(context);
    
    Color primaryColor;
    String name;
    switch (preset) {
      case ThemePreset.classic: primaryColor = AppColors.primaryLight; name = l10n.classicTheme; break;
      case ThemePreset.alexandria: primaryColor = AppColors.alexandriaPrimaryLight; name = l10n.alexandriaTheme; break;
      case ThemePreset.forest: primaryColor = AppColors.forestPrimaryLight; name = l10n.forestTheme; break;
      case ThemePreset.sunset: primaryColor = AppColors.sunsetPrimaryLight; name = l10n.sunsetTheme; break;
      case ThemePreset.sunrise: primaryColor = AppColors.sunrisePrimaryLight; name = l10n.sunriseTheme; break;
      case ThemePreset.lavender: primaryColor = AppColors.lavenderPrimaryLight; name = l10n.lavenderTheme; break;
    }

    return GestureDetector(
      onTap: () => themeModel.setPreset(preset),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                boxShadow: isSelected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 8)] : null,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(ThemeData theme, LocaleModel localeModel, AppLocalizations l10n) {
    final isLight = theme.brightness == Brightness.light;
    final textShadows = isLight ? [Shadow(color: Colors.white.withValues(alpha: 0.9), blurRadius: 4)] : null;
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.language_outlined, size: 22, shadows: textShadows),
          title: Text(l10n.language, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, shadows: textShadows)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localeModel.locale?.languageCode == 'ar' ? l10n.arabic : (localeModel.locale?.languageCode == 'en' ? l10n.english : l10n.system),
                style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold, shadows: textShadows),
              ),
              Icon(Icons.chevron_right, size: 18, shadows: textShadows),
            ],
          ),
          onTap: () => _showLanguageDialog(context, localeModel, l10n),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleModel localeModel, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            RadioListTile<String?>(
              title: Text(l10n.system),
              value: null,
              // ignore: deprecated_member_use
              groupValue: localeModel.locale?.languageCode,
              // ignore: deprecated_member_use
              onChanged: (_) {
                localeModel.clearLocale();
                Navigator.pop(context);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            // ignore: deprecated_member_use
            RadioListTile<String?>(
              title: Text(l10n.english),
              value: 'en',
              // ignore: deprecated_member_use
              groupValue: localeModel.locale?.languageCode,
              // ignore: deprecated_member_use
              onChanged: (_) {
                localeModel.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            // ignore: deprecated_member_use
            RadioListTile<String?>(
              title: Text(l10n.arabic),
              value: 'ar',
              // ignore: deprecated_member_use
              groupValue: localeModel.locale?.languageCode,
              // ignore: deprecated_member_use
              onChanged: (_) {
                localeModel.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
