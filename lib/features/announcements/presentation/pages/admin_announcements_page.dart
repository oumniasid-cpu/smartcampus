import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/announcement_bloc.dart';
import '../../domain/entities/announcement.dart';
import 'package:go_router/go_router.dart'; // ✅ ajouter
// ═══════════════════════════════════════════════════════════════════════════
//  AdminAnnouncementsPage
// ═══════════════════════════════════════════════════════════════════════════
class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AnnouncementsBloc>()..add(AnnouncementsWatchRequested()),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatelessWidget {
  const _AdminView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.onPrimary.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.admin_panel_settings,
                  color: cs.onPrimary, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Admin Panel',
                style: TextStyle(color: cs.onPrimary, fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: cs.onPrimary),
            onPressed: () async => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Announcement'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          if (state is AnnouncementsLoading || state is AnnouncementsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnnouncementsError) {
            return Center(
              child: Text(state.message,
                  style: TextStyle(color: cs.error)),
            );
          }
          if (state is AnnouncementsLoaded) {
            final items = state.announcements;
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 64, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('No announcements yet',
                        style: TextStyle(fontSize: 16,
                            color: cs.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('Tap + to create one',
                        style: TextStyle(fontSize: 13,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                return _AdminCard(
                  announcement: item,
                  onEdit: () => _showDialog(context,
                      announcement: item),
                  onDelete: () => _confirmDelete(context, item.id),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // ── Dialog créer / modifier ──────────────────────────────────────────────
  void _showDialog(BuildContext context, {Announcement? announcement}) {
    final titleCtrl = TextEditingController(text: announcement?.title ?? '');
    final bodyCtrl  = TextEditingController(text: announcement?.body  ?? '');
    final isEdit    = announcement != null;
    final bloc      = context.read<AnnouncementsBloc>();
    final cs        = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Announcement' : 'New Announcement',
          style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('Cancel',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final user = FirebaseAuth.instance.currentUser;

              if (isEdit) {
                bloc.add(AnnouncementUpdateRequested(
                  docId: announcement.id,
                  title: titleCtrl.text.trim(),
                  body:  bodyCtrl.text.trim(),
                ));
              } else {
                bloc.add(AnnouncementAddRequested(
                  title:      titleCtrl.text.trim(),
                  body:       bodyCtrl.text.trim(),
                  authorId:   user?.uid   ?? '',
                  authorName: user?.displayName ?? user?.email ?? 'Admin',
                ));
              }
              dialogContext.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(isEdit ? 'Update' : 'Publish'),
          ),
        ],
      ),
    );
  }

  // ── Dialog supprimer ─────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, String docId) {
    final bloc = context.read<AnnouncementsBloc>();
    final cs   = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Announcement',
            style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
        content: Text('Are you sure? This cannot be undone.',
            style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('Cancel',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              bloc.add(AnnouncementDeleteRequested(docId));
              dialogContext.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Admin Card
// ═══════════════════════════════════════════════════════════════════════════
class _AdminCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final date = announcement.createdAt ?? DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(announcement.title,
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w700, color: cs.onSurface)),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: cs.primary),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14,
                    color: cs.onSurfaceVariant, height: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(announcement.authorName,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${date.day}/${date.month}/${date.year}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}