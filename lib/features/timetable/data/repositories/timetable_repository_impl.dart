import '../../domain/entities/timetable_item.dart';
import '../../domain/timetable_repository.dart';
import '../datasources/timetable_local_datasource.dart';
import '../datasources/timetable_remote_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TimetableRepositoryImpl
//
//  Strategy:
//   1. Try Firestore (remote) first.
//   2. On success → cache locally, return results.
//   3. On failure (offline / error) → return local cache.
//   4. If both fail → return [].
// ─────────────────────────────────────────────────────────────────────────────
class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableRemoteDataSource _remote;
  final TimetableLocalDataSource _local;

  TimetableRepositoryImpl({
    required TimetableRemoteDataSource remote,
    required TimetableLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<List<TimetableItem>> getTimetableForDay(
    TimetableDay day, {
    String? groupId,
  }) async {
    try {
      // 1. Fetch from Firestore
      final remoteItems = await _remote.getTimetableForDay(
        day,
        groupId: groupId,
      );

      // 2. Cache fresh data locally
      await _local.cacheTimetableForDay(day, remoteItems);

      return remoteItems;
    } catch (_) {
      // 3. Firestore failed — fall back to local cache
      final cachedItems = await _local.getCachedTimetableForDay(day);
      return cachedItems;
    }
  }
}