import '../../core/storage/preferences_store.dart';
import '../../models/app_notification.dart';
import 'request_repository.dart';

/// Builds the notifications feed from the tenant's own requests.
///
/// There is no notifications endpoint; instead, any viewing/booking request the
/// owner has acted on (non-pending) becomes a feed item. Read-state is tracked
/// locally by notification id.
class NotificationsRepository {
  NotificationsRepository(this._requests, this._prefs);

  final RequestRepository _requests;
  final PreferencesStore _prefs;

  Future<List<AppNotification>> getNotifications(String tenantId) async {
    // Fetch both request types concurrently (typed separately to preserve
    // element types through the await).
    final viewingsFuture = _requests.getViewings(tenantId: tenantId);
    final bookingsFuture = _requests.getBookings(tenantId: tenantId);
    final viewings = (await viewingsFuture).items;
    final bookings = (await bookingsFuture).items;

    final items = <AppNotification>[];
    for (final v in viewings) {
      final n = AppNotification.fromViewing(v);
      if (n != null) items.add(n);
    }
    for (final b in bookings) {
      final n = AppNotification.fromBooking(b);
      if (n != null) items.add(n);
    }

    final readIds = _prefs.getReadNotificationIds();
    final merged = items
        .map((n) => n.copyWith(isRead: readIds.contains(n.id)))
        .toList()
      ..sort((a, b) {
        final at = a.timestamp?.millisecondsSinceEpoch ?? 0;
        final bt = b.timestamp?.millisecondsSinceEpoch ?? 0;
        return bt.compareTo(at); // newest first
      });

    return merged;
  }

  Future<void> markRead(String id) => _prefs.markRead(id);

  Future<void> markAllRead(Iterable<String> ids) => _prefs.markAllRead(ids);
}
