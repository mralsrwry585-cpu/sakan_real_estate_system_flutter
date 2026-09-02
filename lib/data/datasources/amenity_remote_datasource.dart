import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_executor.dart';
import '../../models/amenity.dart';

/// Talks to the amenities endpoint (grouped by category).
class AmenityRemoteDataSource {
  AmenityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AmenityGroup>> getAmenities({bool includeInactive = false}) =>
      execute(() async {
        final res = await _dio.get(
          ApiEndpoints.amenities,
          queryParameters: {'includeInactive': includeInactive},
        );
        return ((res.data as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AmenityGroup.fromJson)
            .toList(growable: false);
      });
}
