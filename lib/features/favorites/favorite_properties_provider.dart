import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/property.dart';
import '../../providers/app_providers.dart';

/// Resolves the locally-stored favorite ids into live property data.
///
/// Loaded once on entry; the Favorites screen filters this list against the
/// live [favoritesProvider] set so un-favoriting removes an item instantly
/// without a network refetch. Pull-to-refresh invalidates this provider.
final favoritePropertiesProvider =
    FutureProvider.autoDispose<List<PropertyListItem>>((ref) {
  return ref.watch(favoritesRepositoryProvider).getFavoriteProperties();
});
