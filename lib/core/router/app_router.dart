import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/announcements/presentation/pages/announcement_page.dart';
import '../../features/events/presentation/pages/event_page.dart';
import '../../features/settings/presentation/pages/settings _page.dart';

abstract class AppRoutes {
  static const login         = '/login';
  static const home          = '/home';
  static const announcements = '/announcements';
  static const events        = '/events';
  static const settings      = '/settings';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: AppRoutes.announcements,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AnnouncementsPage()),
          ),
          GoRoute(
            path: AppRoutes.events,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EventsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  ScaffoldWithNav — fully theme-aware bottom navigation
//  Compatible with: AGP 8.3.2 · Kotlin 1.9.25 · Gradle 8.13 · Flutter 3.x
//
//  Light mode: Navy (#00193B) + Blue (#0061D4) from AppTheme
//  Dark mode:  follows colorScheme automatically
// ─────────────────────────────────────────────────────────────────────────────
class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.announcements,
    AppRoutes.events,
    AppRoutes.settings,
  ];

  // ── AppTheme constants (mirrored here to avoid cross-import) ──────────────
  static const _navyColor      = Color(0xFF00193B); // AppTheme._primaryColor
  static const _blueColor      = Color(0xFF0061D4); // AppTheme._secondaryColor
  static const _indicatorLight = Color(0xFFE3F0FF); // soft blue tint

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));
    final cs           = Theme.of(context).colorScheme;
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    // ── Resolved colors ─────────────────────────────────────────────────────
    final navBg           = isDark ? cs.surface          : Colors.white;
    final selectedColor   = isDark ? cs.secondary        : _blueColor;
    final unselectedColor = isDark
        ? cs.onSurface.withAlpha(100)   // ~40% — withAlpha replaces deprecated withOpacity
        : _navyColor.withAlpha(90);     // ~35%
    final indicatorColor  = isDark
        ? cs.secondary.withAlpha(46)    // ~18%
        : _indicatorLight;
    final borderColor     = isDark
        ? cs.onSurface.withAlpha(20)    // ~8%
        : const Color(0x1F000000);      // grey 12%

    return Scaffold(
      backgroundColor: cs.surface,
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            height: 68,
            backgroundColor: navBg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            indicatorColor: indicatorColor,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isSelected ? selectedColor : unselectedColor,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 24,
                color: isSelected ? selectedColor : unselectedColor,
              );
            }),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _navyColor.withAlpha(15), // subtle lift
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: currentIndex < 0 ? 0 : currentIndex,
            onDestinationSelected: (i) => context.go(_tabs[i]),
            destinations: const [
              NavigationDestination(
                icon:         Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'HOME',
              ),
              NavigationDestination(
                icon:         Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign_rounded),
                label: 'NEWS',
              ),
              NavigationDestination(
                icon:         Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'EVENTS',
              ),
              NavigationDestination(
                icon:         Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}