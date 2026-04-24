import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import '../../domain/entities/event.dart';
import '../../domain/usecases/events_usecases.dart';
 
// ── Events ───────────────────────────────────────────────────────────────────
abstract class EventsEvent extends Equatable {
  @override List<Object?> get props => [];
}
 
class EventsLoadRequested extends EventsEvent {
  final bool forceRefresh;
  EventsLoadRequested({this.forceRefresh = false});
  @override List<Object?> get props => [forceRefresh];
}
 
class EventPhotoAttached extends EventsEvent {
  final int eventId;
  final String photoPath;
  EventPhotoAttached({required this.eventId, required this.photoPath});
  @override List<Object?> get props => [eventId, photoPath];
}
 
// ── States ───────────────────────────────────────────────────────────────────
abstract class EventsState extends Equatable {
  @override List<Object?> get props => [];
}
 
class EventsInitial  extends EventsState {}
class EventsLoading  extends EventsState {}
 
class EventsLoaded extends EventsState {
  final List<Event> events;
  final bool isOffline;
  EventsLoaded({required this.events, this.isOffline = false});
  @override List<Object?> get props => [events, isOffline];
}
 
class EventsError extends EventsState {
  final String message;
  EventsError(this.message);
  @override List<Object?> get props => [message];
}
 
// ── BLoC ─────────────────────────────────────────────────────────────────────
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEvents getEvents;
  final AttachPhoto attachPhoto;
 
  EventsBloc({required this.getEvents, required this.attachPhoto})
      : super(EventsInitial()) {
    on<EventsLoadRequested>(_onLoad);
    on<EventPhotoAttached>(_onPhotoAttached);
  }
 
  Future<void> _onLoad(
    EventsLoadRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    try {
      final result = await getEvents(GetEventsParams(forceRefresh: event.forceRefresh));
      emit(EventsLoaded(events: result));
    } catch (_) {
      emit(EventsError('Impossible de charger les événements.'));
    }
  }
 
  Future<void> _onPhotoAttached(
    EventPhotoAttached event,
    Emitter<EventsState> emit,
  ) async {
    await attachPhoto(AttachPhotoParams(
      eventId: event.eventId,
      photoPath: event.photoPath,
    ));
    // Reload to reflect photo update
    add(EventsLoadRequested());
  }
}