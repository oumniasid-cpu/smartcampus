import 'package:sqflite/sqflite.dart';
 
import '../../../../core/error/exceptions.dart';
import '../models/announcement_model.dart';
 
abstract class AnnouncementsLocalDataSource {
  Future<List<AnnouncementModel>> getCachedAnnouncements();
  Future<void> cacheAnnouncements(List<AnnouncementModel> announcements);
}
 
class AnnouncementsLocalDataSourceImpl implements AnnouncementsLocalDataSource {
  final Database db;
  AnnouncementsLocalDataSourceImpl(this.db);
 
  @override
  Future<List<AnnouncementModel>> getCachedAnnouncements() async {
    try {
      final maps = await db.query('announcements', orderBy: 'cachedAt DESC');
      if (maps.isEmpty) throw const CacheException('No cached announcements');
      return maps.map((m) => AnnouncementModel.fromMap(m)).toList();
    } catch (e) {
      throw const CacheException();
    }
  }
 
  @override
  Future<void> cacheAnnouncements(List<AnnouncementModel> announcements) async {
    try {
      final batch = db.batch();
      batch.delete('announcements');
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final a in announcements) {
        batch.insert('announcements', a.toMap(cachedAt: now),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw const CacheException('Failed to cache announcements');
    }
  }
}