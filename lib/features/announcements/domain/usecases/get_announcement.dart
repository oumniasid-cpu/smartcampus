import '../../../../core/usecases/usecase.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';
 
class GetAnnouncementsParams {
  final bool forceRefresh;
  const GetAnnouncementsParams({this.forceRefresh = false});
}
 
class GetAnnouncements implements UseCase<List<Announcement>, GetAnnouncementsParams> {
  final AnnouncementsRepository repository;
  GetAnnouncements(this.repository);
 
  @override
  Future<List<Announcement>> call(GetAnnouncementsParams params) {
    return repository.getAnnouncements(forceRefresh: params.forceRefresh);
  }
}