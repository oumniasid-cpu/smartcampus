import '../entities/announcement.dart';

abstract class AnnouncementsRepository {
  /// Stream temps-réel depuis Firestore
  Stream<List<Announcement>> watchAnnouncements();

  /// Créer une nouvelle annonce
  Future<void> addAnnouncement({
    required String title,
    required String body,
    required String authorId,
    required String authorName,
  });

  /// Modifier une annonce existante
  Future<void> updateAnnouncement({
    required String docId,
    required String title,
    required String body,
  });

  /// Supprimer une annonce
  Future<void> deleteAnnouncement(String docId);
}