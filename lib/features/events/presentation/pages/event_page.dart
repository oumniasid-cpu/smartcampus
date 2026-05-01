import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/event.dart';
import '../bloc/events_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Page entry point
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
//  Main scaffold
//  BUG CORRIGÉ : backgroundColor était const Color(0xFFF5F5F5) (hardcodé,
//  invisible en dark mode) → remplacé par cs.surface
//  BUG CORRIGÉ : BottomNavigationBar avec couleurs hardcodées → cs.*
//  BUG CORRIGÉ : 'Aucun événement.' était en français en dur → l10n
// ─────────────────────────────────────────────────────────────────────────────
class _EventsView extends StatelessWidget {
  const _EventsView();

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!; // ← NOUVEAU

    return Scaffold(
      // BUG CORRIGÉ : était Color(0xFFF5F5F5)
      backgroundColor: cs.surface,
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
                      ? Center(
                          // BUG CORRIGÉ : était 'Aucun événement.' (français en dur)
                          child: Text(l10n.noEvents,
                              style: TextStyle(color: cs.onSurfaceVariant)))
                      : _EventsList(events: state.events),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),

    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Scrollable events list with section header
// ─────────────────────────────────────────────────────────────────────────────
class _EventsList extends StatelessWidget {
  final List<Event> events;
  const _EventsList({required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.upcomingEvents, // ← était 'Upcoming Events'
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    l10n.viewCalendar, // ← était 'View Calendar →'
                    style: const TextStyle(
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

// ─────────────────────────────────────────────────────────────────────────────
//  Individual event card
// ─────────────────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  Color _badgeColor(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC': return const Color(0xFFE8F0FE);
      case 'SOCIAL':   return const Color(0xFFFFF9C4);
      case 'SPORTS':   return const Color(0xFFFFEBEE);
      default:         return const Color(0xFFEEEEEE);
    }
  }

  Color _badgeTextColor(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC': return const Color(0xFF1565C0);
      case 'SOCIAL':   return const Color(0xFF795548);
      case 'SPORTS':   return const Color(0xFFC62828);
      default:         return Colors.black54;
    }
  }

  String _primaryLabel(String? category, AppLocalizations l10n) {
    switch ((category ?? '').toUpperCase()) {
      case 'SPORTS': return l10n.getTickets;   // ← était 'Get Tickets'
      case 'SOCIAL': return l10n.interested;   // ← était 'Interested'
      default:       return l10n.rsvpNow;      // ← était 'RSVP Now'
    }
  }

  String _secondaryLabel(String? category, AppLocalizations l10n) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC': return l10n.attachNote;  // ← était 'Attach Note'
      default:         return l10n.attachPhoto; // ← était 'Attach Photo'
    }
  }

  IconData _secondaryIcon(String? category) {
    switch ((category ?? '').toUpperCase()) {
      case 'ACADEMIC': return Icons.note_alt_outlined;
      default:         return Icons.camera_alt_outlined;
    }
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.dateToConfirm; // ← était 'Date à confirmer'
    final now  = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return '${l10n.tonight} • ${DateFormat('h:00 a').format(date)}';   // ← était 'Tonight'
    if (diff == 1) return '${l10n.tomorrow} • ${DateFormat('h:00 a').format(date)}';  // ← était 'Tomorrow'
    return '${DateFormat('EEE, d MMM').format(date)} • ${DateFormat('h:00 a').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context)!;
    final category = event.category;
    final dateStr  = _formatDate(event.date, l10n);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // BUG CORRIGÉ : était Colors.white hardcodé
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderImage(height: 160),
              )
            else
              const _PlaceholderImage(height: 160),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Badge(
                        // BUG CORRIGÉ : fallback était 'EVENT' hardcodé
                        label: category?.toUpperCase() ?? l10n.event.toUpperCase(),
                        bgColor: _badgeColor(category),
                        textColor: _badgeTextColor(category),
                      ),
                      Text(dateStr,
                          style: const TextStyle(fontSize: 12,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(event.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E),
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (event.location != null) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(event.location!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12,
                                  color: Color(0xFF888888))),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (event.attendeeCount != null) ...[
                        const Icon(Icons.people_outline,
                            size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 3),
                        Text('${event.attendeeCount} ${l10n.attending}', // ← était 'attending'
                            style: const TextStyle(fontSize: 12,
                                color: Color(0xFF888888))),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        child: Text(_primaryLabel(category, l10n)),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(_secondaryIcon(category), size: 15),
                        label: Text(_secondaryLabel(category, l10n)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF444444),
                          side: const BorderSide(color: Color(0xFFCCCCCC)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w500),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _Badge({required this.label, required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: textColor, letterSpacing: 0.5)),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double height;
  const _PlaceholderImage({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, width: double.infinity,
      color: const Color(0xFF1A1A2E),
      child: const Icon(Icons.person_outline, size: 72,
          color: Color(0xFF3A7BD5)),
    );
  }
}