import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/announcements/data/datasources/announcement_local_datasource.dart';
import '../../features/announcements/data/datasources/announcement_remote_datasource.dart';
import '../../features/announcements/data/repositories/announcement_repository_impl.dart';
import '../../features/announcements/domain/repositories/announcement_repository.dart';
import '../../features/announcements/domain/usecases/get_announcement.dart';
import '../../features/announcements/presentation/bloc/announcement_bloc.dart';
import '../../features/events/data/datasources/event_local_datasource.dart';
import '../../features/events/data/datasources/event_remote_datasource.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/events_usecases.dart';
import '../../features/events/presentation/bloc/events_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/timetable/data/datasources/timetable_local_datasource.dart';
import '../../features/timetable/domain/timetable_repository.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
 
final getIt = GetIt.instance;
 
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  getIt.registerLazySingleton(() => prefs);
  getIt.registerLazySingleton(() => secureStorage);
  getIt.registerLazySingleton(() => Connectivity());
 
  final db = await _initDatabase();
  getIt.registerLazySingleton(() => db);
 
  getIt.registerLazySingleton<Dio>(() =>
      ApiClient.create(secureStorage: secureStorage));
 
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
 
  // Announcements
  getIt.registerLazySingleton<AnnouncementsRemoteDataSource>(
      () => AnnouncementsRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AnnouncementsLocalDataSource>(
      () => AnnouncementsLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AnnouncementsRepository>(
      () => AnnouncementsRepositoryImpl(
            remoteDataSource: getIt(),
            localDataSource: getIt(),
            networkInfo: getIt(),
          ));
  getIt.registerLazySingleton(() => GetAnnouncements(getIt()));
  getIt.registerFactory(() => AnnouncementsBloc(getAnnouncements: getIt()));
 
  // Events
  getIt.registerLazySingleton<EventsRemoteDataSource>(
      () => EventsRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<EventsLocalDataSource>(
      () => EventsLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<EventsRepository>(
      () => EventsRepositoryImpl(
            remoteDataSource: getIt(),
            localDataSource: getIt(),
            networkInfo: getIt(),
          ));
  getIt.registerLazySingleton(() => GetEvents(getIt()));
  getIt.registerLazySingleton(() => GetEventById(getIt()));
  getIt.registerLazySingleton(() => AttachPhoto(getIt()));
  getIt.registerFactory(() => EventsBloc(
        getEvents: getIt(),
        attachPhoto: getIt(),
      ));
 
  // Timetable
  getIt.registerLazySingleton<TimetableLocalDataSource>(
      () => TimetableLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<TimetableRepository>(
      () => TimetableRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton(() => GetTimetable(getIt()));
  getIt.registerLazySingleton(() => GetTimetableForDay(getIt()));
  getIt.registerLazySingleton(() => ExportTimetableJson(getIt()));
 
  // Settings
  getIt.registerFactory(() => SettingsBloc(prefs: getIt()));
}
 
Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  return openDatabase(
    p.join(dbPath, 'smartcampus.db'),
    version: 2,
    onCreate: (db, version) async => _createTables(db),
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) await _createTables(db);
    },
  );
}
 
Future<void> _createTables(Database db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS announcements (
    id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL,
    userId INTEGER, cachedAt INTEGER NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL,
    userId INTEGER, date INTEGER, location TEXT, photoPath TEXT,
    cachedAt INTEGER NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS timetable (
    id INTEGER PRIMARY KEY, subject TEXT NOT NULL, teacher TEXT NOT NULL,
    room TEXT NOT NULL, day INTEGER NOT NULL, startTime TEXT NOT NULL,
    endTime TEXT NOT NULL, description TEXT, cachedAt INTEGER NOT NULL)''');
}