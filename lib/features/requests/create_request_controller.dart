import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/request_repository.dart';
import '../../models/booking_request.dart';
import '../../models/viewing_request.dart';
import '../../providers/app_providers.dart';
import 'requests_providers.dart';

/// Drives submission of a single viewing/booking request.
///
/// Exposes an [AsyncValue] the form watches for a loading spinner and inline
/// error. On success it invalidates the "my requests" lists and returns the
/// created entity (so the success screen can show its number/id).
class CreateRequestController extends StateNotifier<AsyncValue<void>> {
  CreateRequestController(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  final RequestRepository _repo;
  final Ref _ref;

  Future<ViewingRequest?> submitViewing(CreateViewingRequest request) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repo.createViewing(request);
      state = const AsyncValue.data(null);
      _ref.invalidate(myViewingsProvider);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<BookingRequest?> submitBooking(CreateBookingRequest request) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repo.createBooking(request);
      state = const AsyncValue.data(null);
      _ref.invalidate(myBookingsProvider);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final createRequestControllerProvider = StateNotifierProvider.autoDispose<
    CreateRequestController, AsyncValue<void>>(
  (ref) => CreateRequestController(ref.watch(requestRepositoryProvider), ref),
);
