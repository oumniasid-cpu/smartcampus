import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_datasource.dart';
import '../datasources/event_remote_datasource.dart';

 
class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;
  final EventsLocalDataSource  localDataSource;
  final NetworkInfo networkInfo;
 
  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
 
  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remote = await remoteDataSource.getEvents();
        await localDataSource.cacheEvents(remote);
        return remote;
      } on NetworkException {
        return _getCached();
      } on ServerException {
        return _getCached();
      }
    }
    return _getCached();
  }
 
  @override
  Future<Event> getEventById(int id) async {
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      return remoteDataSource.getEventById(id);
    }
    final cached = await localDataSource.getCachedEvents();
    return cached.firstWhere(
      (e) => e.id == id,
      orElse: () => throw const CacheException('Event not found in cache'),
    );
  }
 
  @override
  Future<void> attachPhoto(int eventId, String photoPath) async {
    await localDataSource.updateEventPhoto(eventId, photoPath);
  }
 
  Future<List<Event>> _getCached() async {
    try {
      return await localDataSource.getCachedEvents();
    } on CacheException {
      return [];
    }
  }
}