import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AJOUT : imports Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile_service.dart'; // adapte le chemin selon ton projet

// ─────────────────────────────────────────────────────────────────────────────
//  Keys SharedPreferences (inchangés)
// ─────────────────────────────────────────────────────────────────────────────
const _kThemeMode    = 'theme_mode';
const _kLanguage     = 'language';
const _kNotifications = 'notifications_enabled';

// ─────────────────────────────────────────────────────────────────────────────
//  Events — on ajoute ProfileLoaded et SignOutRequested
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

// NOUVEAU : déclenché quand le profil Firestore est reçu
class SettingsProfileLoaded extends SettingsEvent {
  final UserProfile profile;
  SettingsProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

// NOUVEAU : l'utilisateur appuie sur "Se déconnecter"
class SettingsSignOutRequested extends SettingsEvent {}

// ─────────────────────────────────────────────────────────────────────────────
//  State — on ajoute les champs du profil et isSignedOut
// ─────────────────────────────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;

  // NOUVEAU : données du profil Firebase
  final String displayName;
  final String email;
  final String role;
  final List<String> badges;
  final bool isLoadingProfile;
  final bool isSignedOut; // true → l'app doit naviguer vers LoginPage

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'fr',
    this.notificationsEnabled = true,
    this.displayName = '',
    this.email = '',
    this.role = 'student',
    this.badges = const [],
    this.isLoadingProfile = true,
    this.isSignedOut = false,
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
    bool? isSignedOut,
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
        isSignedOut: isSignedOut ?? this.isSignedOut,
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
    isSignedOut,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  BLoC — on ajoute la lecture Firebase et la déconnexion
// ─────────────────────────────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;
  // NOUVEAU : le service Firebase
  final UserProfileService _profileService = UserProfileService();

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    // NOUVEAU
    on<SettingsProfileLoaded>(_onProfileLoaded);
    on<SettingsSignOutRequested>(_onSignOut);
  }

  // ── Chargement initial ───────────────────────────────────────────────────
  Future<void> _onLoad(
      SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    // 1. Restaurer les préférences locales (comme avant)
    final themeIndex = prefs.getInt(_kThemeMode) ?? ThemeMode.system.index;
    emit(state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      languageCode: prefs.getString(_kLanguage) ?? 'fr',
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
      isLoadingProfile: true,
    ));

    // 2. NOUVEAU : charger le profil depuis Firestore
    final uid = _profileService.currentUser?.uid;
    if (uid == null) return; // pas connecté

    // On écoute le profil en temps réel grâce à emit.forEach
    // → chaque fois que Firestore change, le BLoC émet un nouvel état
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

    // NOUVEAU : synchroniser aussi dans Firestore (optionnel mais recommandé)
    final uid = _profileService.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('user_settings').doc(uid).set({
        'theme': event.themeMode.name, // 'system', 'light', ou 'dark'
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge:true = ne pas écraser les autres champs
    }
  }

  // ── Langue ───────────────────────────────────────────────────────────────
  Future<void> _onLanguageChanged(
      SettingsLanguageChanged event, Emitter<SettingsState> emit) async {
    await prefs.setString(_kLanguage, event.languageCode);
    emit(state.copyWith(languageCode: event.languageCode));

    // NOUVEAU : synchroniser dans Firestore
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

    // NOUVEAU : synchroniser dans Firestore
    final uid = _profileService.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('user_settings').doc(uid).set({
        'notificationsEnabled': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ── Profil reçu de Firebase ──────────────────────────────────────────────
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

  // ── Déconnexion ──────────────────────────────────────────────────────────
  Future<void> _onSignOut(
      SettingsSignOutRequested event, Emitter<SettingsState> emit) async {
    await _profileService.signOut();
    emit(state.copyWith(isSignedOut: true));
    // Dans SettingsPage, écoute isSignedOut et navigue vers LoginPage
  }
}