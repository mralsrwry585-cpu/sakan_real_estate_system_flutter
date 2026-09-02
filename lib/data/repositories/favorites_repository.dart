import '../../core/network/api_exception.dart';
import '../../core/storage/favorites_store.dart';
import '../../models/property.dart';
import '../datasources/property_remote_datasource.dart';

/// Favorites are local device state (no backend endpoint). This repository
/// resolves the stored favorite ids into live property data on demand, and
/// prunes ids whose property no longer exists.
class FavoritesRepository {
  FavoritesRepository(this._store, this._properties);

  final FavoritesStore _store;
  final PropertyRemoteDataSource _properties;

  List<String> getIds() => _store.getAll();
  Set<String> getIdSet() => _store.getAllSet();
  bool isFavorite(String id) => _store.isFavorite(id);

  Future<bool> toggle(String id) => _store.toggle(id);

  /// Resolves favorite ids to properties. Missing (404) properties are pruned
  /// from local storage; other transient failures are skipped for this load.
  Future<List<PropertyListItem>> getFavoriteProperties() async {
    final ids = _store.getAll();
    if (ids.isEmpty) return const [];

    final results = await Future.wait(
      ids.map((id) async {
        try {
          final details = await _properties.getProperty(id);
          return PropertyListItem.fromDetails(details);
        } on ApiException catch (e) {
          if (e.kind == ApiErrorKind.notFound) {
            await _store.remove(id); // prune stale favorite
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );

    return results.whereType<PropertyListItem>().toList(growable: false);
  }
}
