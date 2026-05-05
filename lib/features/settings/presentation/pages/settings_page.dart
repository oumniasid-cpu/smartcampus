<<<<<<< HEAD
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../bloc/settings_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  SettingsPage — fully theme-aware (dark mode) + localized + Firebase
// ═══════════════════════════════════════════════════════════════════════════
=======
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartcampus/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/settings_bloc.dart';

>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final cs = Theme.of(context).colorScheme;
=======
    final cs   = Theme.of(context).colorScheme;
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs, l10n),
<<<<<<< HEAD
      body: BlocConsumer<SettingsBloc, SettingsState>(
        // MODIFIÉ : BlocConsumer au lieu de BlocBuilder
        // → listener gère la navigation, builder gère l'UI
        listener: (context, state) {
          // NOUVEAU : quand l'utilisateur se déconnecte, on navigue vers Login
          if (state.isSignedOut) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          final isDark = state.themeMode == ThemeMode.dark;
          final notifOn = state.notificationsEnabled;

          return Directionality(
            textDirection: l10n.textDirection,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                // ── Profile header ────────────────────────────────────────
                
=======
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDark  = state.themeMode == ThemeMode.dark;
          final notifOn = state.notificationsEnabled;

          return Directionality(
            textDirection: TextDirection.ltr,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                _ProfileHeader(
                  l10n: l10n,
                  displayName: state.displayName,
                  role: state.role,
                  badges: state.badges,
                  isLoading: state.isLoadingProfile,
<<<<<<< HEAD
                  onEdit: () => context.push('/settings/edit-profile'),
                  email: state.email,
                ),
                const SizedBox(height: 20),

                // ── Preferences ───────────────────────────────────────────
=======
                ),
                const SizedBox(height: 20),

>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                _SectionCard(
                  icon: Icons.tune_rounded,
                  title: l10n.preferences,
                  children: [
                    _ToggleRow(
                      title: l10n.darkTheme,
                      subtitle: l10n.darkThemeDesc,
                      value: isDark,
                      onChanged: (v) => context.read<SettingsBloc>().add(
<<<<<<< HEAD
                        SettingsThemeChanged(
                          v ? ThemeMode.dark : ThemeMode.light,
                        ),
=======
                        SettingsThemeChanged(v ? ThemeMode.dark : ThemeMode.light),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                      ),
                    ),
                    _Divider(),
                    _ToggleRow(
                      title: l10n.notifications,
                      subtitle: l10n.notificationsDesc,
                      value: notifOn,
<<<<<<< HEAD
                      onChanged: (_) => context.read<SettingsBloc>().add(
                        SettingsNotificationsToggled(),
                      ),
                    ),
                  ],
                ),
            
                // ── Language ──────────────────────────────────────────────
=======
                      onChanged: (_) => context.read<SettingsBloc>().add(SettingsNotificationsToggled()),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  icon: Icons.cloud_outlined,
                  title: l10n.cloudStorage,
                  children: [_StorageWidget(l10n: l10n)],
                ),
                const SizedBox(height: 14),

>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                _SectionCard(
                  icon: Icons.language_outlined,
                  title: l10n.language,
                  children: [
                    _LanguageSelector(
                      label: l10n.appLanguage,
                      currentCode: state.languageCode,
                      l10n: l10n,
                      onChanged: (code) {
                        if (code != null) {
<<<<<<< HEAD
                          context.read<SettingsBloc>().add(
                            SettingsLanguageChanged(code),
                          );
=======
                          context.read<SettingsBloc>().add(SettingsLanguageChanged(code));
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

<<<<<<< HEAD
                // ── Account ───────────────────────────────────────────────
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                _SectionCard(
                  icon: Icons.manage_accounts_outlined,
                  title: l10n.account,
                  children: [
<<<<<<< HEAD
                    // In the Account _SectionCard children, BEFORE edit profile:
                    if (state.role == 'admin' || state.role == 'staff') ...[
                      _ActionRow(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin Panel',
                        onTap: () => context.push('/admin'),
=======
                    if (state.role == 'Admin') ...[
                      _ActionRow(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin Panel',
                        onTap: () => context.go(AppRoutes.admin),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                      ),
                      _Divider(),
                    ],
                    _ActionRow(
<<<<<<< HEAD
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () => context.push('/settings/edit-profile'),
                    ),
                    _Divider(),
                    _ActionRow(
                      icon: Icons.lock_outline_rounded,
                      label: l10n.changePassword,
                      onTap: () => context.push('/settings/change-password'),
=======
                      icon: Icons.lock_outline_rounded,
                      label: l10n.changePassword,
                      onTap: () {},
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                    ),
                    _Divider(),
                    _ActionRow(
                      icon: Icons.logout_rounded,
                      label: l10n.signOut,
                      isDestructive: true,
<<<<<<< HEAD
                      // MODIFIÉ : ouvre le dialog de confirmation
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                      onTap: () => _confirmSignOut(context, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n.version,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

<<<<<<< HEAD
  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
=======
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs, AppLocalizations l10n) {
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
    return AppBar(
      backgroundColor: cs.primary,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
<<<<<<< HEAD
            width: 36,
            height: 36,
=======
            width: 36, height: 36,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school_outlined, color: cs.onPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.appName,
<<<<<<< HEAD
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
=======
            style: TextStyle(color: cs.onPrimary, fontSize: 17, fontWeight: FontWeight.bold),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
<<<<<<< HEAD
              icon: Icon(
                Icons.notifications_none_rounded,
                color: cs.onPrimary,
                size: 26,
              ),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D4D),
                  shape: BoxShape.circle,
                ),
=======
              icon: Icon(Icons.notifications_none_rounded, color: cs.onPrimary, size: 26),
              onPressed: () {},
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFFFF4D4D), shape: BoxShape.circle),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }

<<<<<<< HEAD
  // ── Sign-out dialog — MODIFIÉ : appelle maintenant le BLoC ──────────────
  void _confirmSignOut(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    // On garde une référence au BLoC AVANT d'ouvrir le dialog
    // (le context du dialog est différent)
=======
  void _confirmSignOut(BuildContext context, AppLocalizations l10n) {
    final cs   = Theme.of(context).colorScheme;
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
    final bloc = context.read<SettingsBloc>();

    showDialog(
      context: context,
<<<<<<< HEAD
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.signOutConfirmTitle,
          style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface),
        ),
        content: Text(
          l10n.signOutConfirmBody,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // ferme le dialog
              // NOUVEAU : envoie l'event de déconnexion au BLoC
=======
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.signOutConfirmTitle,
            style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
        content: Text(l10n.signOutConfirmBody,
            style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(l10n.cancel, style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              dialogContext.pop();
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              bloc.add(SettingsSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
<<<<<<< HEAD
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
=======
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              elevation: 0,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Profile Header — MODIFIÉ : reçoit les vraies données au lieu du texte dur
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final AppLocalizations l10n;
  // NOUVEAU : paramètres venant de Firestore via le BLoC
  final String displayName;
  final String role;
  final String email;
  final List<String> badges;
  final bool isLoading;
  final VoidCallback onEdit;
=======
class _ProfileHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String displayName;
  final String role;
  final List<String> badges;
  final bool isLoading;
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb

  const _ProfileHeader({
    required this.l10n,
    required this.displayName,
    required this.role,
<<<<<<< HEAD
    required this.email,
    required this.badges,
    required this.isLoading,
    required this.onEdit,
=======
    required this.badges,
    required this.isLoading,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: cs.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      child: Column(
        children: [
<<<<<<< HEAD
          // Avatar + edit button
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
=======
          Stack(
            children: [
              Container(
                width: 110, height: 110,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primaryContainer,
                  boxShadow: [
<<<<<<< HEAD
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
=======
                    BoxShadow(color: cs.shadow.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
<<<<<<< HEAD
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: cs.onPrimaryContainer.withOpacity(0.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 30,
                    height: 30,
=======
                  child: Icon(Icons.person_rounded, size: 60, color: cs.onPrimaryContainer.withOpacity(0.5)),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30, height: 30,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
<<<<<<< HEAD
                        BoxShadow(
                          color: cs.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: cs.onPrimary,
                      size: 15,
                    ),
=======
                        BoxShadow(color: cs.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Icon(Icons.edit_rounded, color: cs.onPrimary, size: 15),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

<<<<<<< HEAD
          // MODIFIÉ : affiche un indicateur de chargement ou le vrai nom
          if (isLoading)
            Container(
              width: 140,
              height: 20,
=======
          if (isLoading)
            Container(
              width: 140, height: 20,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
<<<<<<< HEAD
              displayName.isEmpty ? email  : displayName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          const SizedBox(height: 4),

          // MODIFIÉ : role vient de Firestore
          Text(
          role == 'admin' ? 'Admin' : role == 'staff' ? 'Staff' : l10n.profileRole,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // MODIFIÉ : badges viennent de Firestore
=======
              displayName.isEmpty ? l10n.profileRole : displayName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -0.3),
            ),
          const SizedBox(height: 4),

          Text(
            role == 'Admin' ? 'Administrator' : role == 'staff' ? 'Staff' : l10n.profileRole,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),

>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
          if (badges.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
<<<<<<< HEAD
                if (badges.contains('deans_list'))
                  _Badge(label: l10n.deansList, filled: true),
                if (badges.contains('deans_list') &&
                    badges.contains('junior_scholar'))
                  const SizedBox(width: 8),
                if (badges.contains('junior_scholar'))
                  _Badge(label: l10n.juniorScholar, filled: false),
=======
                if (badges.contains('deans_list')) _Badge(label: l10n.deansList, filled: true),
                if (badges.contains('deans_list') && badges.contains('junior_scholar')) const SizedBox(width: 8),
                if (badges.contains('junior_scholar')) _Badge(label: l10n.juniorScholar, filled: false),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              ],
            ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Badge pill — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _Badge extends StatelessWidget {
  final String label;
  final bool filled;
  const _Badge({required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFF5C518) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
<<<<<<< HEAD
          fontSize: 11,
          fontWeight: FontWeight.w800,
=======
          fontSize: 11, fontWeight: FontWeight.w800,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
          color: filled ? const Color(0xFFB8860B) : cs.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Section Card — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
<<<<<<< HEAD
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });
=======
  const _SectionCard({required this.icon, required this.title, required this.children});
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
<<<<<<< HEAD
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
=======
            BoxShadow(color: cs.shadow.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Icon(icon, color: cs.primary, size: 20),
                  const SizedBox(width: 10),
<<<<<<< HEAD
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
=======
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                ],
              ),
            ),
            Divider(color: cs.surfaceContainerHighest, height: 1, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Toggle Row — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

<<<<<<< HEAD
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
=======
  const _ToggleRow({required this.title, required this.subtitle, required this.value, required this.onChanged});
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
=======
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: cs.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: cs.surfaceContainerHighest,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Language Selector — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _LanguageSelector extends StatelessWidget {
  final String label;
  final String currentCode;
  final AppLocalizations l10n;
  final ValueChanged<String?> onChanged;

  const _LanguageSelector({
    required this.label,
    required this.currentCode,
    required this.l10n,
    required this.onChanged,
  });

  static const _languages = [
    {'code': 'en', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'fr', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'ar', 'flag': '🇩🇿', 'native': 'العربية'},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _languages.map((lang) {
              final code = lang['code']!;
              final flag = lang['flag']!;
              final native = lang['native']!;
=======
          Text(label, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: _languages.map((lang) {
              final code     = lang['code']!;
              final flag     = lang['flag']!;
              final native   = lang['native']!;
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
              final selected = code == currentCode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onChanged(code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
<<<<<<< HEAD
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.primary
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? null
                            : Border.all(color: cs.outline.withOpacity(0.3)),
=======
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: selected ? null : Border.all(color: cs.outline.withOpacity(0.3)),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          Text(
                            native,
                            textAlign: TextAlign.center,
                            style: TextStyle(
<<<<<<< HEAD
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? cs.onPrimary
                                  : cs.onSurfaceVariant,
=======
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(height: 4),
                            Container(
<<<<<<< HEAD
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.onPrimary,
                                shape: BoxShape.circle,
                              ),
=======
                              width: 6, height: 6,
                              decoration: BoxDecoration(color: cs.onPrimary, shape: BoxShape.circle),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Action Row — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

<<<<<<< HEAD
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
=======
  const _ActionRow({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
    final color = isDestructive ? cs.error : cs.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
<<<<<<< HEAD
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
=======
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════════════
//  Internal helpers — inchangé
// ═══════════════════════════════════════════════════════════════════════════
=======

class _StorageWidget extends StatelessWidget {
  final AppLocalizations l10n;
  static const double _usedGb  = 12.4;
  static const double _totalGb = 15.0;

  const _StorageWidget({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final pct = _usedGb / _totalGb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('12.4',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -1)),
              const SizedBox(width: 4),
              Text('GB', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(width: 12),
              Text(l10n.ofGbUsed,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.sync_rounded, size: 13, color: cs.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(l10n.syncedCloud,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(color: cs.surfaceContainerHighest, height: 1, thickness: 1);
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
