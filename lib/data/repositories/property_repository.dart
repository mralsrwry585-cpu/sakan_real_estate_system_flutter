import '../../core/config/app_config.dart';
import '../../core/utils/enums.dart';
import '../../models/paged_result.dart';
import '../../models/property.dart';
import '../../models/property_filter.dart';
import '../../models/property_media.dart';
import '../datasources/property_remote_datasource.dart';

/// Property browsing/search/details.
class PropertyRepository {
  PropertyRepository(this._remote);

  final PropertyRemoteDataSource _remote;

  Future<PagedResult<PropertyListItem>> getProperties(PropertyFilter filter) =>
      _remote.getProperties(filter);

  Future<PropertyDetails> getProperty(String id) => _remote.getProperty(id);

  Future<List<PropertyMedia>> getPropertyMedia(String id) =>
      _remote.getPropertyMedia(id);

  /// A small set of most-viewed available properties for the home hero rail.
  Future<List<PropertyListItem>> getFeatured({int count = 6}) async {
    final result = await _remote.getProperties(
      const PropertyFilter(
        pageNumber: 1,
        pageSize: 6,
        status: PropertyStatus.available,
        sort: PropertySort.mostViewed,
      ).copyWith(pageSize: count),
    );
    return result.items;
  }

  /// First page of newest available properties for the home list.
  Future<PagedResult<PropertyListItem>> getLatest({int page = 1}) =>
      _remote.getProperties(
        PropertyFilter(
          pageNumber: page,
          pageSize: AppConfig.pageSize,
          status: PropertyStatus.available,
          sort: PropertySort.newest,
        ),
      );
}
