import 'package:sqflite/sqflite.dart';
 
import '../../../../core/error/exceptions.dart';
import '../models/event_model.dart';
 
abstract class EventsLocalDataSource {
  Future<List<EventModel>> getCachedEvents();
  Future<void> cacheEvents(List<EventModel> events);
  Future<void> updateEventPhoto(int id, String photoPath);
}
 
class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  final Database db;
  EventsLocalDataSourceImpl(this.db);
 
  @override
  Future<List<EventModel>> getCachedEvents() async {
    try {
      final maps = await db.query('events', orderBy: 'cachedAt DESC');
      if (maps.isEmpty) throw const CacheException('No cached events');
      return maps.map((m) => EventModel.fromMap(m)).toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw const CacheException();
    }
  }
 
  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    try {
      final batch = db.batch();
      batch.delete('events');
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final e in events) {
        batch.insert(
          'events',
          e.toMap(cachedAt: now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw const CacheException('Failed to cache events');
    }
  }
 
  @override
  Future<void> updateEventPhoto(int id, String photoPath) async {
    await db.update(
      'events',
      {'photoPath': photoPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}