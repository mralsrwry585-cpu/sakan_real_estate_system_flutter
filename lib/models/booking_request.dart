import '../core/utils/enums.dart';

/// A booking (rental reservation) request, as returned by the backend.
class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.propertyId,
    required this.propertyTitle,
    required this.ownerId,
    required this.ownerName,
    required this.bookingNumber,
    required this.startDate,
    required this.durationMonths,
    this.note,
    required this.status,
    this.ownerResponseNote,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String tenantName;
  final String propertyId;
  final String propertyTitle;
  final String ownerId;
  final String ownerName;
  final String bookingNumber;
  final DateTime? startDate;
  final int durationMonths;
  final String? note;
  final BookingStatus status;
  final String? ownerResponseNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
        id: (json['id'] ?? '').toString(),
        tenantId: (json['tenantId'] ?? '').toString(),
        tenantName: (json['tenantName'] ?? '').toString(),
        propertyId: (json['propertyId'] ?? '').toString(),
        propertyTitle: (json['propertyTitle'] ?? '').toString(),
        ownerId: (json['ownerId'] ?? '').toString(),
        ownerName: (json['ownerName'] ?? '').toString(),
        bookingNumber: (json['bookingNumber'] ?? '').toString(),
        startDate: _date(json['startDate']),
        durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
        note: json['note']?.toString(),
        status: BookingStatus.fromValue((json['status'] as num?)?.toInt()),
        ownerResponseNote: json['ownerResponseNote']?.toString(),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );
}

/// Request body for `POST /api/bookingrequests`.
class CreateBookingRequest {
  const CreateBookingRequest({
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.durationMonths,
    this.note,
  });

  final String propertyId;
  final String tenantId;
  final DateTime startDate;
  final int durationMonths; // 1..60
  final String? note;

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'tenantId': tenantId,
        'startDate': _isoDate(startDate),
        'durationMonths': durationMonths,
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      };
}

DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

String _isoDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-${day}T00:00:00';
}
