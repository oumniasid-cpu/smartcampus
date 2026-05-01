import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcampus/features/auth/presentation/pages/login_page.dart';
import 'package:smartcampus/l10n/app_localizations.dart';

void main() {
  testWidgets('Login page renders localized strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginPage(),
      ),
    );

    expect(find.text('SmartCampus'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
