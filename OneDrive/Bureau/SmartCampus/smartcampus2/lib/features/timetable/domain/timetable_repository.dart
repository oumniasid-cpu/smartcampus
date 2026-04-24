//import 'package:equatable/equatable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/usecases/usecase.dart';
import '../data/datasources/timetable_local_datasource.dart';
import '../data/models/timetable_item_model.dart';
import '../domain/entities/timetable_item.dart';
 
// ── Repository contract ──────────────────────────────────────────────────────
abstract class TimetableRepository {
  Future<List<TimetableItem>> getTimetable();
  Future<List<TimetableItem>> getTimetableForDay(TimetableDay day);
  Future<String> exportToJson();
}
 
// ── Repository implementation ────────────────────────────────────────────────
class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableLocalDataSource localDataSource;
 
  TimetableRepositoryImpl({required this.localDataSource});
 
  @override
  Future<List<TimetableItem>> getTimetable() async {
    try {
      await localDataSource.seedMockData();
      return await localDataSource.getCachedTimetable();
    } on CacheException {
      return [];
    }
  }
 
  @override
  Future<List<TimetableItem>> getTimetableForDay(TimetableDay day) async {
    final all = await getTimetable();
    return all.where((item) => item.day == day).toList();
  }
 
  @override
  Future<String> exportToJson() async {
    final items = await getTimetable();
    final jsonList = items
        .map((i) => TimetableItemModel.fromMap({
              'id': i.id,
              'subject': i.subject,
              'teacher': i.teacher,
              'room': i.room,
              'day': i.day.index,
              'startTime': i.startTime,
              'endTime': i.endTime,
              'description': i.description,
            }))
        .map((m) => m.toJson())
        .toList();
 
    // Return as formatted JSON string (file write handled in presentation)
    return jsonList.toString();
  }
}
 
// ── Use Cases ────────────────────────────────────────────────────────────────
class GetTimetable implements UseCase<List<TimetableItem>, NoParams> {
  final TimetableRepository repository;
  GetTimetable(this.repository);
 
  @override
  Future<List<TimetableItem>> call(NoParams params) =>
      repository.getTimetable();
}
 
class GetTimetableForDay implements UseCase<List<TimetableItem>, TimetableDay> {
  final TimetableRepository repository;
  GetTimetableForDay(this.repository);
 
  @override
  Future<List<TimetableItem>> call(TimetableDay day) =>
      repository.getTimetableForDay(day);
}
 
class ExportTimetableJson implements UseCase<String, NoParams> {
  final TimetableRepository repository;
  ExportTimetableJson(this.repository);
 
  @override
  Future<String> call(NoParams params) => repository.exportToJson();
}