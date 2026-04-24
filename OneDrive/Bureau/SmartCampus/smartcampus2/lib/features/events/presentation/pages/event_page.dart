import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../domain/entities/event.dart';
import '../bloc/events_bloc.dart';


// ---------------------------------------------------------------------------
// Page entry point
// ---------------------------------------------------------------------------

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EventsBloc>()..add(EventsLoadRequested()),
      child: const _EventsView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main scaffold
// ---------------------------------------------------------------------------

class _EventsView extends StatelessWidget {
  const _EventsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) return const LoadingView();
          if (state is EventsError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<EventsBloc>().add(EventsLoadRequested()),
            );
          }
          if (state is EventsLoaded) {
            return Column(
              children: [
                if (state.isOffline) const OfflineBanner(),
                Expanded(
                  child: state.events.isEmpty
                      ? const Center(child: Text('Aucun événement.'))
                      : _EventsList(events: state.events),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),

      // ── Bottom navigation bar (matches screenshot 3) ──────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
          BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined), label: 'NEWS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined), label: 'EVENTS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scrollable events list with section header
// ---------------------------------------------------------------------------

class _EventsList extends StatelessWidget {
  final List<Event> events;
  const _EventsList({required this.events});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── "Upcoming Events" header ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'View Calendar →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Cards ─────────────────────────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _EventCard(event: events[i]),
            childCount: events.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual event card  (matches screenshots 2 & 3)
// ---------------------------------------------------------------------------

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  // ── Category badge colour ──────────────────────────────────────────────
  Color _badgeColor(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC':
        return const Color(0xFFE8F0FE);
      case 'SOCIAL':
        return const Color(0xFFFFF9C4);
      case 'SPORTS':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFEEEEEE);
    }
  }

  Color _badgeTextColor(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC':
        return const Color(0xFF1565C0);
      case 'SOCIAL':
        return const Color(0xFF795548);
      case 'SPORTS':
        return const Color(0xFFC62828);
      default:
        return Colors.black54;
    }
  }

  // ── Action buttons per category ────────────────────────────────────────
  String _primaryLabel(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'SPORTS':
        return 'Get Tickets';
      case 'SOCIAL':
        return 'Interested';
      default:
        return 'RSVP Now';
    }
  }

  String _secondaryLabel(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC':
        return 'Attach Note';
      default:
        return 'Attach Photo';
    }
  }

  IconData _secondaryIcon(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC':
        return Icons.note_alt_outlined;
      default:
        return Icons.camera_alt_outlined;
    }
  }

  // ── Date string ────────────────────────────────────────────────────────
  String _formatDate(DateTime? date) {
    if (date == null) return 'Date à confirmer';
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return 'Tonight • ${DateFormat('h:00 a').format(date)}';
    if (diff == 1) return 'Tomorrow • ${DateFormat('h:00 a').format(date)}';
    return '${DateFormat('EEE, d MMM').format(date)} • ${DateFormat('h:00 a').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final category = event.category; // nullable String on your entity
    final dateStr = _formatDate(event.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ───────────────────────────────────────────────
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(height: 160),
              )
            else
              _PlaceholderImage(height: 160),

            // ── Card body ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge + date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Badge(
                        label: category?.toUpperCase() ?? 'EVENT',
                        bgColor: _badgeColor(category),
                        textColor: _badgeTextColor(category),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Location + attendees
                  Row(
                    children: [
                      if (event.location != null) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            event.location!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888888)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (event.attendeeCount != null) ...[
                        const Icon(Icons.people_outline,
                            size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 3),
                        Text(
                          '${event.attendeeCount} attending',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888)),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      // Primary CTA
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: Text(_primaryLabel(category)),
                      ),

                      const SizedBox(width: 10),

                      // Secondary CTA
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(_secondaryIcon(category), size: 15),
                        label: Text(_secondaryLabel(category)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF444444),
                          side: const BorderSide(color: Color(0xFFCCCCCC)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double height;
  const _PlaceholderImage({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      child: const Icon(Icons.person_outline, size: 72, color: Color(0xFF3A7BD5)),
    );
  }
}