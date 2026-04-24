import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/l10n/app_localization.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(SettingsLoadRequested()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Convert stored language code → Locale
          final locale = Locale(state.languageCode);

          return MaterialApp.router(
            title: 'SmartCampus',
            debugShowCheckedModeBanner: false,

            // ── Theme ──────────────────────────────────────────────────────
            theme:     AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,

            // ── Locale ─────────────────────────────────────────────────────
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ── Router ─────────────────────────────────────────────────────
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}