import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_executor.dart';
import '../../core/utils/enums.dart';
import '../../models/booking_request.dart';
import '../../models/paged_result.dart';
import '../../models/viewing_request.dart';

/// Talks to the viewing- and booking-request endpoints.
///
/// Note: the requests list endpoints page with a `page` query param (not
/// `pageNumber`), though the response envelope still reports `pageNumber`.
class RequestRemoteDataSource {
  RequestRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Viewing requests ───────────────────────────────────
  Future<ViewingRequest> createViewing(CreateViewingRequest request) =>
      execute(() async {
        final res = await _dio.post(ApiEndpoints.viewingRequests,
            data: request.toJson());
        return ViewingRequest.fromJson(
            (res.data as Map).cast<String, dynamic>());
      });

  Future<PagedResult<ViewingRequest>> getViewings({
    required String tenantId,
    int page = 1,
    int pageSize = 20,
    ViewingStatus? status,
  }) =>
      execute(() async {
        final res = await _dio.get(
          ApiEndpoints.viewingRequests,
          queryParameters: {
            'tenantId': tenantId,
            'page': page,
            'pageSize': pageSize,
            if (status != null) 'status': status.apiName,
          },
        );
        return PagedResult.fromJson(
          (res.data as Map).cast<String, dynamic>(),
          (m) => ViewingRequest.fromJson(m),
        );
      });

  Future<ViewingRequest> getViewing(String id) => execute(() async {
        final res = await _dio.get(ApiEndpoints.viewingRequest(id));
        return ViewingRequest.fromJson(
            (res.data as Map).cast<String, dynamic>());
      });

  // ── Booking requests ───────────────────────────────────
  Future<BookingRequest> createBooking(CreateBookingRequest request) =>
      execute(() async {
        final res = await _dio.post(ApiEndpoints.bookingRequests,
            data: request.toJson());
        return BookingRequest.fromJson(
            (res.data as Map).cast<String, dynamic>());
      });

  Future<PagedResult<BookingRequest>> getBookings({
    required String tenantId,
    int page = 1,
    int pageSize = 20,
    BookingStatus? status,
  }) =>
      execute(() async {
        final res = await _dio.get(
          ApiEndpoints.bookingRequests,
          queryParameters: {
            'tenantId': tenantId,
            'page': page,
            'pageSize': pageSize,
            if (status != null) 'status': status.apiName,
          },
        );
        return PagedResult.fromJson(
          (res.data as Map).cast<String, dynamic>(),
          (m) => BookingRequest.fromJson(m),
        );
      });

  Future<BookingRequest> getBooking(String id) => execute(() async {
        final res = await _dio.get(ApiEndpoints.bookingRequest(id));
        return BookingRequest.fromJson(
            (res.data as Map).cast<String, dynamic>());
      });
}
