import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  final FirebaseFirestore _firestore;

  AnnouncementsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection('announcements');

  // ── Stream temps-réel ────────────────────────────────────────────────────
  @override
  Stream<List<Announcement>> watchAnnouncements() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AnnouncementModel.fromFirestore(doc))
            .toList());
  }

  // ── Créer ────────────────────────────────────────────────────────────────
  @override
  Future<void> addAnnouncement({
    required String title,
    required String body,
    required String authorId,
    required String authorName,
  }) async {
    await _col.add({
      'title':      title,
      'body':       body,
      'authorId':   authorId,
      'authorName': authorName,
      'createdAt':  FieldValue.serverTimestamp(),
      'updatedAt':  FieldValue.serverTimestamp(),
    });
  }

  // ── Modifier ─────────────────────────────────────────────────────────────
  @override
  Future<void> updateAnnouncement({
    required String docId,
    required String title,
    required String body,
  }) async {
    await _col.doc(docId).update({
      'title':     title,
      'body':      body,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Supprimer ────────────────────────────────────────────────────────────
  @override
  Future<void> deleteAnnouncement(String docId) async {
    await _col.doc(docId).delete();
  }
}