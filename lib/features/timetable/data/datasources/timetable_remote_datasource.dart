import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timetable_item.dart';
import '../models/timetable_item_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Abstract interface
// ─────────────────────────────────────────────────────────────────────────────
abstract class TimetableRemoteDataSource {
  /// Returns timetable items for [day], optionally filtered by [groupId].
  Future<List<TimetableItemModel>> getTimetableForDay(
    TimetableDay day, {
    String? groupId,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Firestore implementation
// ─────────────────────────────────────────────────────────────────────────────
class TimetableRemoteDataSourceImpl implements TimetableRemoteDataSource {
  final FirebaseFirestore _db;

  TimetableRemoteDataSourceImpl(this._db);

  @override
  Future<List<TimetableItemModel>> getTimetableForDay(
    TimetableDay day, {
    String? groupId,
  }) async {
    // Always filter by day
    Query<Map<String, dynamic>> query = _db
        .collection('timetable')
        .where('day', isEqualTo: day.name); // e.g. "monday"

    // Narrow to the student's group/section if provided
    if (groupId != null && groupId.isNotEmpty) {
      query = query.where('groupId', isEqualTo: groupId);
    }

    final snapshot = await query.get();

    final items = snapshot.docs
        .map((doc) => TimetableItemModel.fromDoc(doc))
        .toList()
      // Sort by startTime so earliest class appears first
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return items;
  }
}