import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_local_datasource.dart';
import '../datasources/announcement_remote_datasource.dart';
 
class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  final AnnouncementsRemoteDataSource remoteDataSource;
  final AnnouncementsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
 
  AnnouncementsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
 
  @override
  Future<List<Announcement>> getAnnouncements({bool forceRefresh = false}) async {
    final isOnline = await networkInfo.isConnected;
 
    if (isOnline) {
      try {
        final remote = await remoteDataSource.getAnnouncements();
        await localDataSource.cacheAnnouncements(remote);
        return remote;
      } on NetworkException {
        return _getCached();
      } on ServerException {
        return _getCached();
      }
    } else {
      return _getCached();
    }
  }
 
  Future<List<Announcement>> _getCached() async {
    try {
      return await localDataSource.getCachedAnnouncements();
    } on CacheException {
      return [];
    }
  }
}