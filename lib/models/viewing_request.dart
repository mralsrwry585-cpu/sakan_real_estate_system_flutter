import '../core/utils/enums.dart';

/// A viewing (property tour) request, as returned by the backend.
class ViewingRequest {
  const ViewingRequest({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.propertyId,
    required this.propertyTitle,
    required this.ownerId,
    required this.ownerName,
    required this.requestedDate,
    required this.requestedTime,
    this.note,
    required this.status,
    this.ownerResponseNote,
    this.respondedAt,
    required this.createdAt,
  });

  final String id;
  final String tenantId;
  final String tenantName;
  final String propertyId;
  final String propertyTitle;
  final String ownerId;
  final String ownerName;
  final DateTime? requestedDate;
  final String requestedTime; // "HH:mm"
  final String? note;
  final ViewingStatus status;
  final String? ownerResponseNote;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  factory ViewingRequest.fromJson(Map<String, dynamic> json) => ViewingRequest(
        id: (json['id'] ?? '').toString(),
        tenantId: (json['tenantId'] ?? '').toString(),
        tenantName: (json['tenantName'] ?? '').toString(),
        propertyId: (json['propertyId'] ?? '').toString(),
        propertyTitle: (json['propertyTitle'] ?? '').toString(),
        ownerId: (json['ownerId'] ?? '').toString(),
        ownerName: (json['ownerName'] ?? '').toString(),
        requestedDate: _date(json['requestedDate']),
        requestedTime: (json['requestedTime'] ?? '').toString(),
        note: json['note']?.toString(),
        status: ViewingStatus.fromValue((json['status'] as num?)?.toInt()),
        ownerResponseNote: json['ownerResponseNote']?.toString(),
        respondedAt: _date(json['respondedAt']),
        createdAt: _date(json['createdAt']),
      );
}

/// Request body for `POST /api/viewingrequests`.
class CreateViewingRequest {
  const CreateViewingRequest({
    required this.propertyId,
    required this.tenantId,
    required this.requestedDate,
    required this.requestedTime,
    this.note,
  });

  final String propertyId;
  final String tenantId;
  final DateTime requestedDate;
  final String requestedTime; // exactly "HH:mm"
  final String? note;

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'tenantId': tenantId,
        // Date-only ISO (backend requires >= today).
        'requestedDate': _isoDate(requestedDate),
        'requestedTime': requestedTime,
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
