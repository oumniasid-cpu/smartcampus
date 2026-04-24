import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../announcements/presentation/bloc/announcement_bloc.dart';
import '../../../events/presentation/bloc/events_bloc.dart';


// ── UI-only data models ────────────────────────────────────────────────────
class _ScheduleItem {
  final String time;
  final String period;
  final String title;
  final String subtitle;
  final String room;
  final bool isNext;
  const _ScheduleItem({
    required this.time,
    required this.period,
    required this.title,
    required this.subtitle,
    this.room = '',
    this.isNext = false,
  });
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ServiceItem({required this.icon, required this.label, this.onTap});
}

// ═══════════════════════════════════════════════════════════════════════════
//  HomePage
//  FIX 3: removed MultiBlocProvider wrapping AnnouncementsBloc/EventsBloc
//          → each feature page manages its own BLoC instance
//          → HomePage only needs AnnouncementsBloc for the offline banner,
//            registered as a separate BlocProvider scoped to this page only
// ═══════════════════════════════════════════════════════════════════════════
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _schedule = [
    _ScheduleItem(
      time: '09:00', period: 'AM',
      title: 'Advanced Epistemology',
      subtitle: 'Prof. Julian Thorne',
      room: 'Hall B',
      isNext: true,
    ),
    _ScheduleItem(
      time: '11:30', period: 'AM',
      title: 'Ethics & AI Seminar',
      subtitle: 'Research Lab 4 · Group A',
    ),
    _ScheduleItem(
      time: '02:00', period: 'PM',
      title: 'Modern Political Theory',
      subtitle: 'Main Auditorium · Lecture',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // FIX 3: Only AnnouncementsBloc needed here (for offline banner).
    // EventsBloc is NOT provided here — it belongs to EventsPage.
    return BlocProvider(
      create: (_) =>
          getIt<AnnouncementsBloc>()..add(AnnouncementsLoadRequested()),
      child: _HomeScaffold(schedule: _schedule),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HomeScaffold — Scaffold that reads theme colors dynamically
//  FIX 2: All _C.xxx hardcoded colors replaced with Theme/ColorScheme
// ─────────────────────────────────────────────────────────────────────────────
class _HomeScaffold extends StatelessWidget {
  final List<_ScheduleItem> schedule;
  const _HomeScaffold({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // FIX 2: uses theme surface instead of hardcoded Color(0xFFF5F7FA)
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs),
      body: _HomeBody(schedule: schedule),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      // FIX 2: AppBar background comes from theme primary
      backgroundColor: cs.primary,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school_outlined,
                color: cs.onPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'SmartCampus',
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
              icon: Icon(Icons.notifications_none_rounded,
                  color: cs.onPrimary, size: 26),
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
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HomeBody
// ─────────────────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final List<_ScheduleItem> schedule;
  const _HomeBody({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
      builder: (context, state) {
        final isOffline =
            state is AnnouncementsLoaded && state.isOffline;

        return RefreshIndicator(
          color: cs.primary,
          onRefresh: () async {
            context
                .read<AnnouncementsBloc>()
                .add(AnnouncementsLoadRequested(forceRefresh: true));
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (isOffline) ...[
                      _OfflineBanner(
                        onRetry: () => context
                            .read<AnnouncementsBloc>()
                            .add(AnnouncementsLoadRequested(
                                forceRefresh: true)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                    _buildGreeting(context, cs),
                    const SizedBox(height: 6),
                    _buildNextClassHint(context, cs, schedule),
                    const SizedBox(height: 28),
                    _ScheduleSection(schedule: schedule),
                    const SizedBox(height: 28),
                    _CampusServicesSection(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              _MilestoneBanner(),
              const SizedBox(height: 28),
            ],
          ),
        );
      },
    );
  }

  // ── Greeting ──────────────────────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning,',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            // FIX 2: cs.onSurface adapts to light/dark automatically
            color: cs.onSurface,
            height: 1.1,
          ),
        ),
        Text(
          'Alex.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ── Next class hint ───────────────────────────────────────────────────────
  Widget _buildNextClassHint(
    BuildContext context,
    ColorScheme cs,
    List<_ScheduleItem> schedule,
  ) {
    final next = schedule.firstWhere((s) => s.isNext,
        orElse: () => schedule.first);
    return Text(
      'Your first lecture, ${next.title}, starts in 45 minutes in South Wing, ${next.room}.',
      style: TextStyle(
        fontSize: 14,
        // FIX 2: cs.onSurfaceVariant adapts to dark mode
        color: cs.onSurfaceVariant,
        height: 1.55,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Offline Banner
// ─────────────────────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFD966)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFF92660A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Offline Mode Active',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A5200))),
                const SizedBox(height: 2),
                Text(
                  'Displaying cached data from your last sync.',
                  style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF7A5200).withOpacity(0.85),
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF92660A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('RETRY',
                style:
                    TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Schedule Section
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleSection extends StatelessWidget {
  final List<_ScheduleItem> schedule;
  const _ScheduleSection({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    // FIX 2: theme-aware
                    color: cs.onSurface)),
            Text(
              'SEPT 14, TUESDAY',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            // FIX 2: card uses theme surface container
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              schedule.length,
              (i) => _ScheduleRow(
                item: schedule[i],
                isLast: i == schedule.length - 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Schedule Row
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleRow extends StatelessWidget {
  final _ScheduleItem item;
  final bool isLast;
  const _ScheduleRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time
              SizedBox(
                width: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.time,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            // FIX 2
                            color: cs.onSurface)),
                    Text(item.period,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // Accent bar
              Container(
                width: 3,
                height: 52,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  // FIX 2: blue accent from theme, surface from theme
                  color: item.isNext
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface)),
                        ),
                        if (item.isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('UP NEXT',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onPrimary,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(item.subtitle,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                    if (item.room.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(item.room,
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              thickness: 1,
              // FIX 2
              color: cs.surfaceContainerHighest,
              indent: 16,
              endIndent: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Campus Services Section
// ─────────────────────────────────────────────────────────────────────────────
class _CampusServicesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final services = [
      _ServiceItem(
          icon: Icons.restaurant_menu_outlined,
          label: 'Dining Hall\nMenus',
          onTap: () {}),
      _ServiceItem(
          icon: Icons.local_library_outlined,
          label: 'Library\nBooking',
          onTap: () {}),
      _ServiceItem(
          icon: Icons.directions_bus_outlined,
          label: 'Campus\nShuttle',
          onTap: () {}),
      _ServiceItem(
          icon: Icons.support_agent_outlined,
          label: 'Student\nSupport',
          onTap: () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Campus Services',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: services.map((s) => _ServiceCard(item: s)).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Service Card
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      // FIX 2: theme surface
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // FIX 2: surfaceContainerHighest adapts to dark
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Milestone Banner — intentionally dark regardless of theme
// ─────────────────────────────────────────────────────────────────────────────
class _MilestoneBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Milestone is always dark navy — intentional brand choice
        color: const Color(0xFF0D2B5E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('ACADEMIC MILESTONE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 14),
          const Text(
            'Registration for\nSpring Semester\nopens in 12 days.',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.25),
          ),
          const SizedBox(height: 12),
          Text(
            'Review your degree audit and meet with your advisor to clear any holds before the enrollment window begins.',
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.55),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('View Enrollment Guide',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}