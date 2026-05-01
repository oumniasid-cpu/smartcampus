// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localization.dart';
import '../bloc/settings_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  SettingsPage — fully theme-aware (dark mode) + localized + Firebase
// ═══════════════════════════════════════════════════════════════════════════
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs, l10n),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        // MODIFIÉ : BlocConsumer au lieu de BlocBuilder
        // → listener gère la navigation, builder gère l'UI
        listener: (context, state) {
          // NOUVEAU : quand l'utilisateur se déconnecte, on navigue vers Login
          if (state.isSignedOut) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', // adapte selon ta route
              (route) => false,
            );
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
                // MODIFIÉ : on passe maintenant les données réelles du state
                _ProfileHeader(
                  l10n: l10n,
                  displayName: state.displayName,
                  role: state.role,
                  badges: state.badges,
                  isLoading: state.isLoadingProfile,
                ),
                const SizedBox(height: 20),

                // ── Preferences ───────────────────────────────────────────
                _SectionCard(
                  icon: Icons.tune_rounded,
                  title: l10n.preferences,
                  children: [
                    _ToggleRow(
                      title: l10n.darkTheme,
                      subtitle: l10n.darkThemeDesc,
                      value: isDark,
                      onChanged: (v) => context.read<SettingsBloc>().add(
                        SettingsThemeChanged(
                          v ? ThemeMode.dark : ThemeMode.light,
                        ),
                      ),
                    ),
                    _Divider(),
                    _ToggleRow(
                      title: l10n.notifications,
                      subtitle: l10n.notificationsDesc,
                      value: notifOn,
                      onChanged: (_) => context.read<SettingsBloc>().add(
                        SettingsNotificationsToggled(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Cloud Storage ─────────────────────────────────────────
                _SectionCard(
                  icon: Icons.cloud_outlined,
                  title: l10n.cloudStorage,
                  children: [_StorageWidget(l10n: l10n)],
                ),
                const SizedBox(height: 14),

                // ── Language ──────────────────────────────────────────────
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
                          context.read<SettingsBloc>().add(
                            SettingsLanguageChanged(code),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Account ───────────────────────────────────────────────
                _SectionCard(
                  icon: Icons.manage_accounts_outlined,
                  title: l10n.account,
                  children: [
                    _ActionRow(
                      icon: Icons.lock_outline_rounded,
                      label: l10n.changePassword,
                      onTap: () {},
                    ),
                    _Divider(),
                    _ActionRow(
                      icon: Icons.logout_rounded,
                      label: l10n.signOut,
                      isDestructive: true,
                      // MODIFIÉ : ouvre le dialog de confirmation
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

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: cs.primary,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school_outlined, color: cs.onPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.appName,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
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
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // ── Sign-out dialog — MODIFIÉ : appelle maintenant le BLoC ──────────────
  void _confirmSignOut(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    // On garde une référence au BLoC AVANT d'ouvrir le dialog
    // (le context du dialog est différent)
    final bloc = context.read<SettingsBloc>();

    showDialog(
      context: context,
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
              bloc.add(SettingsSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Profile Header — MODIFIÉ : reçoit les vraies données au lieu du texte dur
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final AppLocalizations l10n;
  // NOUVEAU : paramètres venant de Firestore via le BLoC
  final String displayName;
  final String role;
  final List<String> badges;
  final bool isLoading;

  const _ProfileHeader({
    required this.l10n,
    required this.displayName,
    required this.role,
    required this.badges,
    required this.isLoading,
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
          // Avatar + edit button
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                  onTap: () {}, // à implémenter : modifier la photo
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // MODIFIÉ : affiche un indicateur de chargement ou le vrai nom
          if (isLoading)
            Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
              // MODIFIÉ : displayName vient de Firestore (plus de texte en dur)
              displayName.isEmpty ? l10n.profileRole : displayName,
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
            role == 'staff' ? 'Staff' : l10n.profileRole,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // MODIFIÉ : badges viennent de Firestore
          if (badges.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badges.contains('deans_list'))
                  _Badge(label: l10n.deansList, filled: true),
                if (badges.contains('deans_list') &&
                    badges.contains('junior_scholar'))
                  const SizedBox(width: 8),
                if (badges.contains('junior_scholar'))
                  _Badge(label: l10n.juniorScholar, filled: false),
              ],
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Badge pill — inchangé
// ═══════════════════════════════════════════════════════════════════════════
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
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: filled ? const Color(0xFFB8860B) : cs.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Section Card — inchangé
// ═══════════════════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

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
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
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

// ═══════════════════════════════════════════════════════════════════════════
//  Toggle Row — inchangé
// ═══════════════════════════════════════════════════════════════════════════
class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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

// ═══════════════════════════════════════════════════════════════════════════
//  Language Selector — inchangé
// ═══════════════════════════════════════════════════════════════════════════
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
              final selected = code == currentCode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onChanged(code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? cs.onPrimary
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.onPrimary,
                                shape: BoxShape.circle,
                              ),
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

// ═══════════════════════════════════════════════════════════════════════════
//  Action Row — inchangé
// ═══════════════════════════════════════════════════════════════════════════
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Cloud Storage Widget — inchangé (à connecter à Firebase Storage plus tard)
// ═══════════════════════════════════════════════════════════════════════════
class _StorageWidget extends StatelessWidget {
  final AppLocalizations l10n;
  static const double _usedGb = 12.4;
  static const double _totalGb = 15.0;

  const _StorageWidget({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              Text(
                '12.4',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'GB',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.ofGbUsed,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
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
              Text(
                l10n.syncedCloud,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Internal helpers — inchangé
// ═══════════════════════════════════════════════════════════════════════════
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(color: cs.surfaceContainerHighest, height: 1, thickness: 1);
  }
}
