import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
// --- Keys ---
const _kThemeMode = 'theme_mode';
const _kLanguage  = 'language';
const _kNotifications = 'notifications_enabled';
 
// --- Events ---
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
 
// --- State ---
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;
 
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'fr',
    this.notificationsEnabled = true,
  });
 
  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
 
  @override
  List<Object?> get props => [themeMode, languageCode, notificationsEnabled];
}
 
// --- BLoC ---
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;
 
  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
  }
 
  void _onLoad(SettingsLoadRequested event, Emitter<SettingsState> emit) {
    final themeIndex = prefs.getInt(_kThemeMode) ?? ThemeMode.system.index;
    emit(state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      languageCode: prefs.getString(_kLanguage) ?? 'fr',
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
    ));
  }
 
  Future<void> _onThemeChanged(
      SettingsThemeChanged event, Emitter<SettingsState> emit) async {
    await prefs.setInt(_kThemeMode, event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }
 
  Future<void> _onLanguageChanged(
      SettingsLanguageChanged event, Emitter<SettingsState> emit) async {
    await prefs.setString(_kLanguage, event.languageCode);
    emit(state.copyWith(languageCode: event.languageCode));
  }
 
  Future<void> _onNotificationsToggled(
      SettingsNotificationsToggled event, Emitter<SettingsState> emit) async {
    final newValue = !state.notificationsEnabled;
    await prefs.setBool(_kNotifications, newValue);
    emit(state.copyWith(notificationsEnabled: newValue));
  }
}