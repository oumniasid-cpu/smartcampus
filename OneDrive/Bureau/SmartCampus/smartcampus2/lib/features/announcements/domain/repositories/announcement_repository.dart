import '../entities/announcement.dart';
 
abstract class AnnouncementsRepository {
  /// Returns cached list or fetches from remote if online.
  Future<List<Announcement>> getAnnouncements({bool forceRefresh = false});
}