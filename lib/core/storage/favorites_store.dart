import 'package:shared_preferences/shared_preferences.dart';

/// Local favorites: the backend has no favorites endpoint, so a tenant's
/// favorites are real device state — a persisted set of property IDs.
class FavoritesStore {
  FavoritesStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'sakan.favorites';

  /// Current favorite property IDs (insertion order preserved best-effort).
  List<String> getAll() => _prefs.getStringList(_key) ?? const [];

  Set<String> getAllSet() => getAll().toSet();

  bool isFavorite(String id) => getAll().contains(id);

  /// Adds/removes an id and returns the new favorite state (true = favorited).
  Future<bool> toggle(String id) async {
    final list = getAll().toList();
    final wasFavorite = list.remove(id);
    if (!wasFavorite) {
      list.insert(0, id); // newest first
    }
    await _prefs.setStringList(_key, list);
    return !wasFavorite;
  }

  Future<void> remove(String id) async {
    final list = getAll().toList()..remove(id);
    await _prefs.setStringList(_key, list);
  }

  Future<void> clear() => _prefs.remove(_key);
}
