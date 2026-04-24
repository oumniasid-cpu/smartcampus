import '../entities/event.dart';
 
abstract class EventsRepository {
  Future<List<Event>> getEvents({bool forceRefresh = false});
  Future<Event> getEventById(int id);
  Future<void> attachPhoto(int eventId, String photoPath);
}