import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    super.authorId,
    super.authorName,
    super.createdAt,
    super.updatedAt,
  });

  // ── Depuis un document Firestore ─────────────────────────────────────────
  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id:         doc.id,
      title:      data['title']      as String? ?? '',
      body:       data['body']       as String? ?? '',
      authorId:   data['authorId']   as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Admin',
      createdAt:  (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt:  (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── Vers Firestore (pour create/update) ──────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'title':      title,
    'body':       body,
    'authorId':   authorId,
    'authorName': authorName,
    'updatedAt':  FieldValue.serverTimestamp(),
  };
}