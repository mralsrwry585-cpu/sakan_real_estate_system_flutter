import '../../core/utils/enums.dart';
import '../../models/booking_request.dart';
import '../../models/paged_result.dart';
import '../../models/viewing_request.dart';
import '../datasources/request_remote_datasource.dart';

/// Viewing- and booking-request creation and listing for the current tenant.
class RequestRepository {
  RequestRepository(this._remote);

  final RequestRemoteDataSource _remote;

  Future<ViewingRequest> createViewing(CreateViewingRequest request) =>
      _remote.createViewing(request);

  Future<BookingRequest> createBooking(CreateBookingRequest request) =>
      _remote.createBooking(request);

  Future<PagedResult<ViewingRequest>> getViewings({
    required String tenantId,
    int page = 1,
    int pageSize = 50,
    ViewingStatus? status,
  }) =>
      _remote.getViewings(
        tenantId: tenantId,
        page: page,
        pageSize: pageSize,
        status: status,
      );

  Future<PagedResult<BookingRequest>> getBookings({
    required String tenantId,
    int page = 1,
    int pageSize = 50,
    BookingStatus? status,
  }) =>
      _remote.getBookings(
        tenantId: tenantId,
        page: page,
        pageSize: pageSize,
        status: status,
      );
}
