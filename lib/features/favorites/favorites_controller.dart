import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/favorites_store.dart';
import '../../providers/app_providers.dart';

/// Holds the set of favorite property ids in memory (seeded from local
/// storage) and keeps storage in sync on toggle. Any widget can watch this to
/// reflect favorite state instantly across the app.
class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController(this._store) : super(_store.getAllSet());

  final FavoritesStore _store;

  bool isFavorite(String id) => state.contains(id);

  Future<bool> toggle(String id) async {
    final nowFavorite = await _store.toggle(id);
    state = _store.getAllSet();
    return nowFavorite;
  }

  /// Re-reads storage (e.g. after stale favorites were pruned on load).
  void refresh() => state = _store.getAllSet();
}

final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>(
  (ref) => FavoritesController(ref.watch(favoritesStoreProvider)),
);
