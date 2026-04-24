import 'package:dio/dio.dart';
 
import '../../../../core/error/exceptions.dart';
import '../models/event_model.dart';
 
abstract class EventsRemoteDataSource {
  Future<List<EventModel>> getEvents();
  Future<EventModel> getEventById(int id);
}
 
class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final Dio dio;
  EventsRemoteDataSourceImpl(this.dio);
 
  @override
  Future<List<EventModel>> getEvents() async {
    try {
      // JSONPlaceholder /posts reused as events (realistic campus scenario)
      final response = await dio.get('/posts', queryParameters: {'_limit': 15});
      return (response.data as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
    //throw const ServerException();
  }
 
  @override
  Future<EventModel> getEventById(int id) async {
    try {
      final response = await dio.get('/posts/$id');
      return EventModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
    }
    //throw const ServerException();
  }
 
  Never _handleDioError(DioException e) {
    if (e.error is NetworkException) throw e.error as NetworkException;
    if (e.error is AuthException)    throw e.error as AuthException;
    if (e.error is ServerException)  throw e.error as ServerException;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw const NetworkException();
    }
    throw ServerException(e.message ?? 'Unknown server error');
  }
}