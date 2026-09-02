import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve platform singletons that the provider graph needs synchronously.
  final prefs = await SharedPreferences.getInstance();

  // Build the container up front so we can restore the session (and warm the
  // Arabic date symbols) before the first frame — this keeps the router's very
  // first redirect from flickering through the signed-out state.
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Restore any persisted session into the shared in-memory store. This must
  // finish before the auth controller is first read (it reads the session
  // synchronously at construction).
  await container.read(sessionStoreProvider).load();

  // Arabic locale data for intl date/number formatting.
  await initializeDateFormatting('ar', null);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SakanApp(),
    ),
  );
}
