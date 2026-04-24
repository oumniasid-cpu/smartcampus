import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';
 
// ── GetEvents ────────────────────────────────────────────────────────────────
class GetEventsParams {
  final bool forceRefresh;
  const GetEventsParams({this.forceRefresh = false});
}
 
class GetEvents implements UseCase<List<Event>, GetEventsParams> {
  final EventsRepository repository;
  GetEvents(this.repository);
 
  @override
  Future<List<Event>> call(GetEventsParams params) =>
      repository.getEvents(forceRefresh: params.forceRefresh);
}
 
// ── GetEventById ─────────────────────────────────────────────────────────────
class GetEventById implements UseCase<Event, int> {
  final EventsRepository repository;
  GetEventById(this.repository);
 
  @override
  Future<Event> call(int id) => repository.getEventById(id);
}
 
// ── AttachPhoto ──────────────────────────────────────────────────────────────
class AttachPhotoParams {
  final int eventId;
  final String photoPath;
  const AttachPhotoParams({required this.eventId, required this.photoPath});
}
 
class AttachPhoto implements UseCase<void, AttachPhotoParams> {
  final EventsRepository repository;
  AttachPhoto(this.repository);
 
  @override
  Future<void> call(AttachPhotoParams params) =>
      repository.attachPhoto(params.eventId, params.photoPath);
}
 