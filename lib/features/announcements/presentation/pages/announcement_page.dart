import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../bloc/announcement_bloc.dart';
import '../../domain/entities/announcement.dart';
import '../../../../core/l10n/app_localization.dart';

// ── Static brand colors only used for intentionally fixed UI
//    (hero card dark bg, amber featured card, newsletter bg)
//    Everything else uses Theme.of(context).colorScheme
class _Brand {
  static const navyCard   = Color(0xFF0D1F3C);
  static const tealBg     = Color(0xFF0F3D3E);
  static const amberCard  = Color(0xFFFFD97D);
  static const amberText  = Color(0xFFB8860B);
  static const blueSoft   = Color(0xFFE8EFFE);
  static const urgent     = Color(0xFFE53E3E);
  static const safety     = Color(0xFF2B6CB0);
}

// ═══════════════════════════════════════════════════════════════════════════
//  AnnouncementsPage
// ═══════════════════════════════════════════════════════════════════════════
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) =>
          getIt<AnnouncementsBloc>()..add(AnnouncementsLoadRequested()),
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatefulWidget {
  const _NewsView();

  @override
  State<_NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<_NewsView> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // FIX 2: theme-driven background
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          if (state is AnnouncementsLoading || state is AnnouncementsInitial) {
            return _buildSyncingState(cs);
          }
          if (state is AnnouncementsError) {
            return _buildErrorState(context, cs);
          }
          if (state is AnnouncementsLoaded) {
            return _buildContent(context, cs, state.announcements);
          }
          return _buildSyncingState(cs);
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      // FIX 2: uses theme primary
      backgroundColor: cs.primary,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school_outlined,
                color: cs.onPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text('SmartCampus',
              style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
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
              top: 10, right: 10,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFFFF4D4D), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    ColorScheme cs,
    List<Announcement> items,
  ) {
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
          _buildHeader(cs),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeroCard(announcement: items.first),
            ),
          ],
          if (items.length > 1) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FeaturedYellowCard(announcement: items[1]),
            ),
          ],
          const SizedBox(height: 20),
          ...List.generate(
            items.length > 2 ? items.length - 2 : 0,
            (i) {
              final item = items[i + 2];
              final isEvent = i % 3 == 2;
              return Column(
                children: [
                  if (isEvent) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _NewsletterCard(emailCtrl: _emailCtrl),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _EventCard(announcement: item),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _TextNewsCard(announcement: item),
                    ),
                  const SizedBox(height: 14),
                ],
              );
            },
          ),
          if (items.length <= 4) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _NewsletterCard(emailCtrl: _emailCtrl),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CAMPUS BULLETIN',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  // FIX 2: secondary color from theme
                  color: cs.secondary,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  // FIX 2: theme onSurface
                  color: cs.onSurface,
                  height: 1.2),
              children: [
                const TextSpan(text: "What's happening\n"),
                TextSpan(
                    text: 'on campus.',
                    style: TextStyle(color: cs.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Syncing state ─────────────────────────────────────────────────────────
  Widget _buildSyncingState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: cs.primary,
              backgroundColor: cs.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text('Syncing feed...',
              style: TextStyle(
                  fontSize: 14,
                  // FIX 2
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Error / Connection Lost state ─────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.cloud_off_rounded,
                color: cs.onErrorContainer, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Connection Lost',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          Text("We couldn't reach the campus\nnews server.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  height: 1.5)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context
                .read<AnnouncementsBloc>()
                .add(AnnouncementsLoadRequested(forceRefresh: true)),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Hero Card — intentionally dark (brand design, not theme-driven)
// ═══════════════════════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final Announcement announcement;
  const _HeroCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: _Brand.tealBg,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -10, right: -10,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(Icons.eco_rounded,
                        size: 120, color: Colors.tealAccent),
                  ),
                ),
                Positioned(
                  bottom: -10, left: -10,
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(Icons.eco_rounded,
                        size: 90, color: Colors.tealAccent),
                  ),
                ),
                Center(
                  child: Text('Campus\nEvents',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.tealAccent.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                          height: 1.1)),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: _Brand.navyCard,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Tag(label: 'URGENT', color: _Brand.urgent),
                    const SizedBox(width: 8),
                    _Tag(
                        label: 'SAFETY',
                        color: _Brand.safety,
                        outlined: true),
                  ],
                ),
                const SizedBox(height: 12),
                Text(announcement.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25)),
                const SizedBox(height: 8),
                Text(announcement.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.5)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      _navigateToDetail(context, announcement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        cs.primary.withOpacity(0.25),
                    foregroundColor: const Color(0xFF93B4FF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(
                        color: Color(0xFF93B4FF), width: 0.5),
                  ),
                  child: const Text('Read Protocol',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Featured Yellow Card — intentional amber color, not theme-driven
// ═══════════════════════════════════════════════════════════════════════════
class _FeaturedYellowCard extends StatelessWidget {
  final Announcement announcement;
  const _FeaturedYellowCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, announcement),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _Brand.amberCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: Color(0xFF0A1931), size: 22),
            ),
            const SizedBox(height: 12),
            Text(announcement.title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1931),
                    height: 1.2)),
            const SizedBox(height: 6),
            Text(announcement.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF0A1931).withOpacity(0.7),
                    height: 1.45)),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('7 Days Left',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A1931))),
                const Spacer(),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xFF0A1931), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Text News Card — fully theme-aware
// ═══════════════════════════════════════════════════════════════════════════
class _TextNewsCard extends StatelessWidget {
  final Announcement announcement;
  const _TextNewsCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, announcement),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // FIX 2: surfaceContainerLowest is white in light, dark in dark
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryPill(label: 'ACADEMIC'),
                Text('2h ago',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(announcement.title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.25)),
            const SizedBox(height: 8),
            Text(announcement.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.55)),
            const SizedBox(height: 14),
            Divider(color: cs.surfaceContainerHighest, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionIcon(icon: Icons.share_outlined, onTap: () {}),
                const SizedBox(width: 16),
                _ActionIcon(
                    icon: Icons.bookmark_border_rounded, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Event Card — theme-aware
// ═══════════════════════════════════════════════════════════════════════════
class _EventCard extends StatelessWidget {
  final Announcement announcement;
  const _EventCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, announcement),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64, height: 64,
                color: cs.primary,
                child: Icon(Icons.business_center_outlined,
                    color: cs.onPrimary.withOpacity(0.5), size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('EVENT',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: cs.secondary,
                              letterSpacing: 0.5)),
                      const SizedBox(width: 6),
                      Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                              color: cs.onSurfaceVariant,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Today',
                          style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(announcement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          height: 1.25)),
                  const SizedBox(height: 4),
                  Text('Grand Hall, 10:00 AM ...',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Newsletter Card — intentional fixed blue-soft bg, not theme-driven
// ═══════════════════════════════════════════════════════════════════════════
class _NewsletterCard extends StatelessWidget {
  final TextEditingController emailCtrl;
  const _NewsletterCard({required this.emailCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The Weekly Scholar',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                  height: 1.2)),
          const SizedBox(height: 6),
          Text(
            'Subscribe to get the curated campus digest in your inbox every Monday.',
            style: TextStyle(
                fontSize: 13,
                color: cs.onPrimaryContainer.withOpacity(0.8),
                height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  alignment: Alignment.center, // Added: Centers the TextField vertically
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textAlignVertical: TextAlignVertical.center, // Added: Aligns text to center
                    style: TextStyle(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: cs.onSurfaceVariant, 
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      isCollapsed: false, // Changed: Standard behavior handles height better
                      isDense: true,      // Added: Keeps the field compact
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.send_rounded,
                      color: cs.onPrimary, size: 20),
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
//  Reusable small widgets
// ═══════════════════════════════════════════════════════════════════════════
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  const _Tag({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(20),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: outlined ? color : Colors.white,
              letterSpacing: 0.4)),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // FIX 2: theme surface container
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.4)),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: cs.onSurfaceVariant, size: 22),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Navigation + Detail page
// ═══════════════════════════════════════════════════════════════════════════
void _navigateToDetail(BuildContext context, Announcement announcement) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _AnnouncementDetailPage(announcement: announcement),
    ),
  );
}

class _AnnouncementDetailPage extends StatelessWidget {
  final Announcement announcement;
  const _AnnouncementDetailPage({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.share_outlined, color: cs.onSurface),
              onPressed: () {}),
          IconButton(
              icon: Icon(Icons.bookmark_border_rounded, color: cs.onSurface),
              onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryPill(label: 'ACADEMIC'),
                const SizedBox(width: 8),
                Text('2h ago',
                    style: TextStyle(
                        fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            Text(announcement.title,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    height: 1.2)),
            const SizedBox(height: 16),
            Divider(color: cs.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text(announcement.body,
                style: TextStyle(
                    fontSize: 15,
                    color: cs.onSurfaceVariant,
                    height: 1.7)),
          ],
        ),
      ),
    );
  }
}