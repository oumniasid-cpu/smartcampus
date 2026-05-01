import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  LocaleNotifier — singleton ValueNotifier that drives MaterialApp.locale
//
//  Usage in main.dart / app.dart:
//
//    void main() async {
//      WidgetsFlutterBinding.ensureInitialized();
//      await LocaleNotifier.instance.load(); // restore saved locale
//      runApp(const MyApp());
//    }
//
//    // Inside your MaterialApp (or MaterialApp.router):
//    ValueListenableBuilder<Locale>(
//      valueListenable: LocaleNotifier.instance,
//      builder: (_, locale, __) => MaterialApp.router(
//        locale: locale,
//        supportedLocales: AppLocalizations.supportedLocales,
//        localizationsDelegates: AppLocalizations.localizationsDelegates,
//        routerConfig: appRouter,
//      ),
//    );
//
//  Changing language (e.g. from SettingsPage or SettingsBloc):
//
//    LocaleNotifier.instance.setLocale('ar');
// ═══════════════════════════════════════════════════════════════════════════

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier._() : super(const Locale('fr'));

  static final LocaleNotifier instance = LocaleNotifier._();

  static const _prefKey = 'app_locale';

  /// Restore the locale persisted from the previous session.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && ['ar', 'en', 'fr'].contains(code)) {
      value = Locale(code);
    }
  }

  /// Change the app locale and persist the choice.
  Future<void> setLocale(String languageCode) async {
    if (!['ar', 'en', 'fr'].contains(languageCode)) return;
    value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
  }
}