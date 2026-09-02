import '../../models/amenity.dart';
import '../datasources/amenity_remote_datasource.dart';

/// Amenities lookup, cached in memory for the app lifetime (rarely changes).
class AmenityRepository {
  AmenityRepository(this._remote);

  final AmenityRemoteDataSource _remote;
  List<AmenityGroup>? _cache;

  Future<List<AmenityGroup>> getAmenities({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;
    final groups = await _remote.getAmenities();
    _cache = groups;
    return groups;
  }
}
