import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────
abstract class AnnouncementsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnnouncementsWatchRequested extends AnnouncementsEvent {}

class AnnouncementsUpdated extends AnnouncementsEvent {
  final List<Announcement> announcements;
  AnnouncementsUpdated(this.announcements);
  @override
  List<Object?> get props => [announcements];
}

class AnnouncementAddRequested extends AnnouncementsEvent {
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  AnnouncementAddRequested({
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
  });
  @override
  List<Object?> get props => [title, body, authorId, authorName];
}

class AnnouncementUpdateRequested extends AnnouncementsEvent {
  final String docId;
  final String title;
  final String body;
  AnnouncementUpdateRequested({
    required this.docId,
    required this.title,
    required this.body,
  });
  @override
  List<Object?> get props => [docId, title, body];
}

class AnnouncementDeleteRequested extends AnnouncementsEvent {
  final String docId;
  AnnouncementDeleteRequested(this.docId);
  @override
  List<Object?> get props => [docId];
}

// ── States ───────────────────────────────────────────────────────────────────
abstract class AnnouncementsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnnouncementsInitial  extends AnnouncementsState {}
class AnnouncementsLoading  extends AnnouncementsState {}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> announcements;
  AnnouncementsLoaded({required this.announcements});
  @override
  List<Object?> get props => [announcements];
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  AnnouncementsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ─────────────────────────────────────────────────────────────────────
class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final AnnouncementsRepository repository;
  StreamSubscription<List<Announcement>>? _sub;

  AnnouncementsBloc({required this.repository}) : super(AnnouncementsInitial()) {
    on<AnnouncementsWatchRequested>(_onWatch);
    on<AnnouncementsUpdated>(_onUpdated);
    on<AnnouncementAddRequested>(_onAdd);
    on<AnnouncementUpdateRequested>(_onUpdate);
    on<AnnouncementDeleteRequested>(_onDelete);
  }

  // ── Écoute temps-réel ────────────────────────────────────────────────────
  Future<void> _onWatch(
    AnnouncementsWatchRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(AnnouncementsLoading());
    await _sub?.cancel();
    await emit.forEach<List<Announcement>>(
      repository.watchAnnouncements(),
      onData: (list) => AnnouncementsLoaded(announcements: list),
      onError: (_, __) => AnnouncementsError('Impossible de charger les annonces.'),
    );
  }

  // ── Reçoit les nouvelles données du stream ───────────────────────────────
  void _onUpdated(AnnouncementsUpdated event, Emitter<AnnouncementsState> emit) {
    emit(AnnouncementsLoaded(announcements: event.announcements));
  }

  // ── Ajouter ──────────────────────────────────────────────────────────────
  Future<void> _onAdd(
    AnnouncementAddRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    try {
      await repository.addAnnouncement(
        title:      event.title,
        body:       event.body,
        authorId:   event.authorId,
        authorName: event.authorName,
      );
      // Le stream met à jour l'UI automatiquement
    } catch (e) {
      emit(AnnouncementsError('Erreur lors de la création : $e'));
    }
  }

  // ── Modifier ─────────────────────────────────────────────────────────────
  Future<void> _onUpdate(
    AnnouncementUpdateRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    try {
      await repository.updateAnnouncement(
        docId: event.docId,
        title: event.title,
        body:  event.body,
      );
    } catch (e) {
      emit(AnnouncementsError('Erreur lors de la mise à jour : $e'));
    }
  }

  // ── Supprimer ────────────────────────────────────────────────────────────
  Future<void> _onDelete(
    AnnouncementDeleteRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    try {
      await repository.deleteAnnouncement(event.docId);
    } catch (e) {
      emit(AnnouncementsError('Erreur lors de la suppression : $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}