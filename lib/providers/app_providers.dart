import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/storage/favorites_store.dart';
import '../core/storage/preferences_store.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/session_store.dart';
import '../data/datasources/amenity_remote_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/property_remote_datasource.dart';
import '../data/datasources/request_remote_datasource.dart';
import '../data/repositories/amenity_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/property_repository.dart';
import '../data/repositories/request_repository.dart';

// ── Platform singletons ──────────────────────────────────
/// Overridden in `main` with the resolved instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// Bumped by the Dio interceptor on a 401. The auth controller watches this to
/// reset itself to signed-out — an indirection that avoids a DI cycle between
/// the HTTP client and the auth controller.
final sessionRevisionProvider = StateProvider<int>((ref) => 0);

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionStore(ref.watch(secureStorageProvider)),
);

final favoritesStoreProvider = Provider<FavoritesStore>(
  (ref) => FavoritesStore(ref.watch(sharedPreferencesProvider)),
);

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => PreferencesStore(ref.watch(sharedPreferencesProvider)),
);

// ── HTTP client ──────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(sessionStoreProvider);
  return DioClient.create(
    // Read synchronously from the in-memory session on every request.
    tokenProvider: () => session.token,
    onUnauthorized: () {
      // Drop the session (in-memory clear is synchronous) and signal the auth
      // controller to reset via the revision counter — no direct reference,
      // which keeps the provider graph acyclic.
      session.clear();
      ref.read(sessionRevisionProvider.notifier).state++;
    },
  );
});

// ── Datasources ──────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final propertyRemoteDataSourceProvider = Provider<PropertyRemoteDataSource>(
  (ref) => PropertyRemoteDataSource(ref.watch(dioProvider)),
);

final amenityRemoteDataSourceProvider = Provider<AmenityRemoteDataSource>(
  (ref) => AmenityRemoteDataSource(ref.watch(dioProvider)),
);

final requestRemoteDataSourceProvider = Provider<RequestRemoteDataSource>(
  (ref) => RequestRemoteDataSource(ref.watch(dioProvider)),
);

// ── Repositories ─────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final propertyRepositoryProvider = Provider<PropertyRepository>(
  (ref) => PropertyRepository(ref.watch(propertyRemoteDataSourceProvider)),
);

final amenityRepositoryProvider = Provider<AmenityRepository>(
  (ref) => AmenityRepository(ref.watch(amenityRemoteDataSourceProvider)),
);

final requestRepositoryProvider = Provider<RequestRepository>(
  (ref) => RequestRepository(ref.watch(requestRemoteDataSourceProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(
    ref.watch(favoritesStoreProvider),
    ref.watch(propertyRemoteDataSourceProvider),
  ),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(
    ref.watch(requestRepositoryProvider),
    ref.watch(preferencesStoreProvider),
  ),
);
