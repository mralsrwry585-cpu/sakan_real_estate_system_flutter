/// Property address / geolocation.
class Address {
  const Address({
    required this.id,
    required this.city,
    required this.district,
    required this.street,
    this.postalCode,
    this.buildingNumber,
    this.floor,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String city;
  final String district;
  final String street;
  final String? postalCode;
  final String? buildingNumber;
  final String? floor; // Backend `AddressDto.Floor` is a string (e.g. "3", "الأرضي").
  final double latitude;
  final double longitude;

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  /// Human-readable one-liner: "الحي، الشارع".
  String get shortLine {
    final parts = [district, street].where((p) => p.trim().isNotEmpty);
    return parts.join('، ');
  }

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: (json['id'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        district: (json['district'] ?? '').toString(),
        street: (json['street'] ?? '').toString(),
        postalCode: json['postalCode']?.toString(),
        buildingNumber: json['buildingNumber']?.toString(),
        floor: json['floor']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      );
}
