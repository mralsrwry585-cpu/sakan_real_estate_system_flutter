// Boot smoke test for the SAKAN tenant app.
//
// Verifies the app builds without exceptions, renders the branded splash on the
// first frame, and — with no persisted session — routes to the login screen.
// No network is exercised: the provider graph is built with an empty in-memory
// session, so the router redirects an unauthenticated user to login.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sakan_app/app/app.dart';
import 'package:sakan_app/core/localization/app_strings.dart';
import 'package:sakan_app/providers/app_providers.dart';
import 'package:sakan_app/widgets/sakan_logo.dart';

void main() {
  testWidgets('boots to splash, then routes to login when signed out',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SakanApp(),
      ),
    );

    // First frame shows the branded splash (with its progress indicator).
    expect(find.byType(SakanLogo), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // The splash holds ~1300ms, then routes by auth state. Fire that timer and
    // let the route transition complete. (pumpAndSettle is unusable here: the
    // splash's progress indicator animates forever.)
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    // Signed out → login screen is shown, splash is gone.
    expect(find.text(S.welcomeBack), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
