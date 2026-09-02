import '../core/utils/enums.dart';
import 'booking_request.dart';
import 'viewing_request.dart';

enum NotificationKind { viewing, booking }

/// Tone for the notification's leading icon/color.
enum NotificationTone { approved, rejected, completed, neutral }

/// A notification derived from a request whose status changed.
///
/// The backend has no notifications endpoint, so the feed is built from the
/// tenant's own viewing/booking requests: any request the owner has acted on
/// (non-pending) becomes an item. Read-state is tracked locally by id.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.tone,
    required this.title,
    required this.body,
    required this.propertyId,
    required this.propertyTitle,
    required this.requestId,
    required this.timestamp,
    this.ownerResponseNote,
    this.isRead = false,
  });

  final String id;
  final NotificationKind kind;
  final NotificationTone tone;
  final String title;
  final String body;
  final String propertyId;
  final String propertyTitle;
  final String requestId;
  final DateTime? timestamp;
  final String? ownerResponseNote;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        kind: kind,
        tone: tone,
        title: title,
        body: body,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        requestId: requestId,
        timestamp: timestamp,
        ownerResponseNote: ownerResponseNote,
        isRead: isRead ?? this.isRead,
      );

  /// Builds a notification from a viewing request, or null if still pending.
  static AppNotification? fromViewing(ViewingRequest r) {
    if (r.status == ViewingStatus.pending) return null;
    final tone = switch (r.status) {
      ViewingStatus.approved => NotificationTone.approved,
      ViewingStatus.rejected => NotificationTone.rejected,
      ViewingStatus.completed => NotificationTone.completed,
      ViewingStatus.cancelled => NotificationTone.neutral,
      ViewingStatus.pending => NotificationTone.neutral,
    };
    final title = switch (r.status) {
      ViewingStatus.approved => 'تم قبول طلب المعاينة',
      ViewingStatus.rejected => 'تم رفض طلب المعاينة',
      ViewingStatus.completed => 'اكتملت المعاينة',
      ViewingStatus.cancelled => 'أُلغيت المعاينة',
      ViewingStatus.pending => 'طلب معاينة',
    };
    return AppNotification(
      id: 'v_${r.id}_${r.status.value}',
      kind: NotificationKind.viewing,
      tone: tone,
      title: title,
      body: r.propertyTitle,
      propertyId: r.propertyId,
      propertyTitle: r.propertyTitle,
      requestId: r.id,
      timestamp: r.respondedAt ?? r.createdAt,
      ownerResponseNote: r.ownerResponseNote,
    );
  }

  /// Builds a notification from a booking request, or null if still pending.
  static AppNotification? fromBooking(BookingRequest r) {
    if (r.status == BookingStatus.pending) return null;
    final tone = switch (r.status) {
      BookingStatus.approved => NotificationTone.approved,
      BookingStatus.rejected => NotificationTone.rejected,
      BookingStatus.completed => NotificationTone.completed,
      BookingStatus.cancelled => NotificationTone.neutral,
      BookingStatus.pending => NotificationTone.neutral,
    };
    final title = switch (r.status) {
      BookingStatus.approved => 'تم قبول طلب الحجز',
      BookingStatus.rejected => 'تم رفض طلب الحجز',
      BookingStatus.completed => 'اكتمل الحجز',
      BookingStatus.cancelled => 'أُلغي الحجز',
      BookingStatus.pending => 'طلب حجز',
    };
    return AppNotification(
      id: 'b_${r.id}_${r.status.value}',
      kind: NotificationKind.booking,
      tone: tone,
      title: title,
      body: '${r.propertyTitle} · ${r.bookingNumber}',
      propertyId: r.propertyId,
      propertyTitle: r.propertyTitle,
      requestId: r.id,
      timestamp: r.updatedAt ?? r.createdAt,
      ownerResponseNote: r.ownerResponseNote,
    );
  }
}
