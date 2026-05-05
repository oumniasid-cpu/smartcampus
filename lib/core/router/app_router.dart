import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/announcements/presentation/pages/announcement_page.dart';
import '../../features/announcements/presentation/pages/admin_announcements_page.dart';
import '../../features/events/presentation/pages/event_page.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

abstract class AppRoutes {
  static const login         = '/login';
  static const home          = '/home';
  static const announcements = '/announcements';
  static const events        = '/events';
  static const settings      = '/settings';
  static const admin         = '/admin'; // ✅ NOUVEAU
}

class AppRouter {
  static final _routerNotifier = _AuthNotifier();

  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    refreshListenable: _routerNotifier,
    redirect: (context, state) {
      final isLoggedIn = _routerNotifier.isLoggedIn;
      final isOnLogin  = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isOnLogin) return AppRoutes.login;
      if (isLoggedIn && isOnLogin)   return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      // ✅ Route Admin — en dehors du ShellRoute (pas de navbar)
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AdminAnnouncementsPage()),
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) =>
                    getIt<SettingsBloc>()..add(SettingsLoadRequested()),
                child: const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      isLoggedIn = user != null;
      notifyListeners();
    });
  }
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.announcements,
    AppRoutes.events,
    AppRoutes.settings,
  ];

  static const _navyColor      = Color(0xFF00193B);
  static const _blueColor      = Color(0xFF0061D4);
  static const _indicatorLight = Color(0xFFE3F0FF);

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));
    final cs           = Theme.of(context).colorScheme;
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    final navBg           = isDark ? cs.surface     : Colors.white;
    final selectedColor   = isDark ? cs.secondary   : _blueColor;
    final unselectedColor = isDark
        ? cs.onSurface.withAlpha(100)
        : _navyColor.withAlpha(90);
    final indicatorColor  = isDark
        ? cs.secondary.withAlpha(46)
        : _indicatorLight;
    final borderColor     = isDark
        ? cs.onSurface.withAlpha(20)
        : const Color(0x1F000000);

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
            border: Border(top: BorderSide(color: borderColor, width: 1)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: _navyColor.withAlpha(15),
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
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign_rounded),
                label: 'NEWS',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'EVENTS',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
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