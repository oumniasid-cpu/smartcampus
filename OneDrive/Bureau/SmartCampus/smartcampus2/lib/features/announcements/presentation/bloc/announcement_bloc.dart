import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/usecases/get_announcement.dart';
 
// --- Events ---
abstract class AnnouncementsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
 
class AnnouncementsLoadRequested extends AnnouncementsEvent {
  final bool forceRefresh;
  AnnouncementsLoadRequested({this.forceRefresh = false});
  @override
  List<Object?> get props => [forceRefresh];
}
 
// --- States ---
abstract class AnnouncementsState extends Equatable {
  @override
  List<Object?> get props => [];
}
 
class AnnouncementsInitial extends AnnouncementsState {}
 
class AnnouncementsLoading extends AnnouncementsState {}
 
class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> announcements;
  final bool isOffline;
  AnnouncementsLoaded({required this.announcements, this.isOffline = false});
  @override
  List<Object?> get props => [announcements, isOffline];
}
 
class AnnouncementsError extends AnnouncementsState {
  final String message;
  AnnouncementsError(this.message);
  @override
  List<Object?> get props => [message];
}
 
// --- BLoC ---
class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final GetAnnouncements getAnnouncements;
 
  AnnouncementsBloc({required this.getAnnouncements})
      : super(AnnouncementsInitial()) {
    on<AnnouncementsLoadRequested>(_onLoad);
  }
 
  Future<void> _onLoad(
    AnnouncementsLoadRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(AnnouncementsLoading());
    try {
      final result = await getAnnouncements(
        GetAnnouncementsParams(forceRefresh: event.forceRefresh),
      );
      emit(AnnouncementsLoaded(announcements: result));
    } catch (e) {
      emit(AnnouncementsError('Impossible de charger les annonces.'));
    }
  }
}