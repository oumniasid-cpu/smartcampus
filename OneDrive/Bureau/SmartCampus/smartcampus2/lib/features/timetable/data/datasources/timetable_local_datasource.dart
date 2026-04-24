import 'package:sqflite/sqflite.dart';
 
import '../../../../core/error/exceptions.dart';
import '../models/timetable_item_model.dart';
 
abstract class TimetableLocalDataSource {
  Future<List<TimetableItemModel>> getCachedTimetable();
  Future<void> cacheTimetable(List<TimetableItemModel> items);
  /// Seed mock data when no real API endpoint is available
  Future<void> seedMockData();
}
 
class TimetableLocalDataSourceImpl implements TimetableLocalDataSource {
  final Database db;
  TimetableLocalDataSourceImpl(this.db);
 
  @override
  Future<List<TimetableItemModel>> getCachedTimetable() async {
    try {
      final maps = await db.query('timetable', orderBy: 'day ASC, startTime ASC');
      if (maps.isEmpty) throw const CacheException('No cached timetable');
      return maps.map((m) => TimetableItemModel.fromMap(m)).toList();
    } on CacheException {
      rethrow;
    } catch (_) {
      throw const CacheException();
    }
  }
 
  @override
  Future<void> cacheTimetable(List<TimetableItemModel> items) async {
    try {
      final batch = db.batch();
      batch.delete('timetable');
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final item in items) {
        batch.insert('timetable', item.toMap(cachedAt: now),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (_) {
      throw const CacheException('Failed to cache timetable');
    }
  }
 
  @override
  Future<void> seedMockData() async {
    final existing = await db.query('timetable', limit: 1);
    if (existing.isNotEmpty) return; // Already seeded
    await cacheTimetable(TimetableItemModel.mockData);
  }
}