import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile_service.dart';

const _kThemeMode     = 'theme_mode';
const _kLanguage      = 'language';
const _kNotifications = 'notifications_enabled';

// ─────────────────────────────────────────────────────────────────────────────
//  Events
// ─────────────────────────────────────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;
  SettingsThemeChanged(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class SettingsLanguageChanged extends SettingsEvent {
  final String languageCode;
  SettingsLanguageChanged(this.languageCode);
  @override
  List<Object?> get props => [languageCode];
}

class SettingsNotificationsToggled extends SettingsEvent {}

class SettingsProfileLoaded extends SettingsEvent {
  final UserProfile profile;
  SettingsProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class SettingsSignOutRequested extends SettingsEvent {}

// ─────────────────────────────────────────────────────────────────────────────
//  State — isSignedOut SUPPRIMÉ
// ─────────────────────────────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;
  final String displayName;
  final String email;
  final String role;
  final List<String> badges;
  final bool isLoadingProfile;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'fr',
    this.notificationsEnabled = true,
    this.displayName = '',
    this.email = '',
    this.role = 'student',
    this.badges = const [],
    this.isLoadingProfile = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
    String? displayName,
    String? email,
    String? role,
    List<String>? badges,
    bool? isLoadingProfile,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        role: role ?? this.role,
        badges: badges ?? this.badges,
        isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      );

  @override
  List<Object?> get props => [
        themeMode,
        languageCode,
        notificationsEnabled,
        displayName,
        email,
        role,
        badges,
        isLoadingProfile,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  BLoC
// ─────────────────────────────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;
  final UserProfileService _profileService = UserProfileService();

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsProfileLoaded>(_onProfileLoaded);
    on<SettingsSignOutRequested>(_onSignOut);
  }

  // ── Chargement initial ───────────────────────────────────────────────────
  Future<void> _onLoad(
      SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    final themeIndex = prefs.getInt(_kThemeMode) ?? ThemeMode.system.index;
    emit(state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      languageCode: prefs.getString(_kLanguage) ?? 'fr',
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
      isLoadingProfile: true,
    ));

    final uid = _profileService.currentUser?.uid;
    if (uid == null) return;

    await emit.forEach<UserProfile?>(
      _profileService.watchProfile(uid),
      onData: (profile) {
        if (profile == null) return state;
        return state.copyWith(
          displayName: profile.displayName,
          email: profile.email,
          role: profile.role,
          badges: profile.badges,
          isLoadingProfile: false,
        );
      },
      onError: (_, __) => state.copyWith(isLoadingProfile: false),
    );
  }

  // ── Thème ────────────────────────────────────────────────────────────────
  Future<void> _onThemeChanged(
      SettingsThemeChanged event, Emitter<SettingsState> emit) async {
    await prefs.setInt(_kThemeMode, event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));

    final uid = _profileService.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('user_settings').doc(uid).set({
        'theme': event.themeMode.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ── Langue ───────────────────────────────────────────────────────────────
  Future<void> _onLanguageChanged(
      SettingsLanguageChanged event, Emitter<SettingsState> emit) async {
    await prefs.setString(_kLanguage, event.languageCode);
    emit(state.copyWith(languageCode: event.languageCode));

    final uid = _profileService.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('user_settings').doc(uid).set({
        'language': event.languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ── Notifications ────────────────────────────────────────────────────────
  Future<void> _onNotificationsToggled(
      SettingsNotificationsToggled event, Emitter<SettingsState> emit) async {
    final newValue = !state.notificationsEnabled;
    await prefs.setBool(_kNotifications, newValue);
    emit(state.copyWith(notificationsEnabled: newValue));

    final uid = _profileService.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('user_settings').doc(uid).set({
        'notificationsEnabled': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ── Profil reçu ──────────────────────────────────────────────────────────
  void _onProfileLoaded(
      SettingsProfileLoaded event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      displayName: event.profile.displayName,
      email: event.profile.email,
      role: event.profile.role,
      badges: event.profile.badges,
      isLoadingProfile: false,
    ));
  }

  // ── Déconnexion — appelle UNIQUEMENT FirebaseAuth.signOut() ──────────────
  // GoRouter (_AuthNotifier) détecte le changement et redirige vers /login
  // automatiquement. Pas besoin d'émettre un état ou de naviguer ici.
  Future<void> _onSignOut(
      SettingsSignOutRequested event, Emitter<SettingsState> emit) async {
    await _profileService.signOut();
  }
}