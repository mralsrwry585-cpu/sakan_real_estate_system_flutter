import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_executor.dart';
import '../../models/paged_result.dart';
import '../../models/property.dart';
import '../../models/property_filter.dart';
import '../../models/property_media.dart';

/// Talks to the property endpoints.
class PropertyRemoteDataSource {
  PropertyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PagedResult<PropertyListItem>> getProperties(
          PropertyFilter filter) =>
      execute(() async {
        final res = await _dio.get(
          ApiEndpoints.properties,
          queryParameters: filter.toQueryParameters(),
        );
        return PagedResult.fromJson(
          (res.data as Map).cast<String, dynamic>(),
          (m) => PropertyListItem.fromJson(m),
        );
      });

  Future<PropertyDetails> getProperty(String id) => execute(() async {
        final res = await _dio.get(ApiEndpoints.property(id));
        return PropertyDetails.fromJson(
            (res.data as Map).cast<String, dynamic>());
      });

  Future<List<PropertyMedia>> getPropertyMedia(String id) => execute(() async {
        final res = await _dio.get(ApiEndpoints.propertyMedia(id));
        return ((res.data as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PropertyMedia.fromJson)
            .toList(growable: false);
      });
}
