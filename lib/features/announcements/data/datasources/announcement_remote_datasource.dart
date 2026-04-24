import 'package:dio/dio.dart';
 
import '../../../../core/error/exceptions.dart';
import '../models/announcement_model.dart';
 
abstract class AnnouncementsRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements();
}
 
class AnnouncementsRemoteDataSourceImpl implements AnnouncementsRemoteDataSource {
  final Dio dio;
  AnnouncementsRemoteDataSourceImpl(this.dio);
 
  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await dio.get('/posts', queryParameters: {'_limit': 20});
      return (response.data as List)
          .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}