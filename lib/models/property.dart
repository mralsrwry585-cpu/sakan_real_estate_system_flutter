import '../core/config/app_config.dart';
import '../core/utils/enums.dart';
import 'address.dart';
import 'amenity.dart';
import 'property_media.dart';

/// Lightweight property as returned by the list endpoint (`PropertyListDto`).
class PropertyListItem {
  const PropertyListItem({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.contractType,
    required this.price,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.status,
    required this.views,
    required this.viewingRequestsCount,
    required this.bookingRequestsCount,
    required this.city,
    required this.district,
    this.coverImageUrl,
    required this.createdAt,
  });

  final String id;
  final String title;
  final PropertyType propertyType;
  final ContractType contractType;
  final double price;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final PropertyStatus status;
  final int views;
  final int viewingRequestsCount;
  final int bookingRequestsCount;
  final String city;
  final String district;
  final String? coverImageUrl;
  final DateTime? createdAt;

  /// Location one-liner: "الحي، المدينة".
  String get locationLine {
    final parts = [district, city].where((p) => p.trim().isNotEmpty);
    return parts.join('، ');
  }

  /// Absolute cover image URL, or null when none was provided.
  String? get resolvedCoverUrl {
    final u = coverImageUrl?.trim();
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base${u.startsWith('/') ? u : '/$u'}';
  }

  factory PropertyListItem.fromJson(Map<String, dynamic> json) =>
      PropertyListItem(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        propertyType:
            PropertyType.fromValue((json['propertyType'] as num?)?.toInt()),
        contractType:
            ContractType.fromValue((json['contractType'] as num?)?.toInt()),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        area: (json['area'] as num?)?.toDouble() ?? 0,
        bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
        bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
        status: PropertyStatus.fromValue((json['status'] as num?)?.toInt()),
        views: (json['views'] as num?)?.toInt() ?? 0,
        viewingRequestsCount:
            (json['viewingRequestsCount'] as num?)?.toInt() ?? 0,
        bookingRequestsCount:
            (json['bookingRequestsCount'] as num?)?.toInt() ?? 0,
        city: (json['city'] ?? '').toString(),
        district: (json['district'] ?? '').toString(),
        coverImageUrl: json['coverImageUrl']?.toString(),
        createdAt: _parseDate(json['createdAt']),
      );

  /// Adapts a full [PropertyDetails] into a list item (used by favorites,
  /// which fetch details per id since there's no batch endpoint).
  factory PropertyListItem.fromDetails(PropertyDetails d) {
    final cover = d.media.where((m) => m.mediaType == 0).toList()
      ..sort((a, b) {
        if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
    return PropertyListItem(
      id: d.id,
      title: d.title,
      propertyType: d.propertyType,
      contractType: d.contractType,
      price: d.price,
      area: d.area,
      bedrooms: d.bedrooms,
      bathrooms: d.bathrooms,
      status: d.status,
      views: d.views,
      viewingRequestsCount: 0,
      bookingRequestsCount: 0,
      city: d.city,
      district: d.district,
      coverImageUrl: cover.isEmpty ? null : cover.first.url,
      createdAt: d.createdAt,
    );
  }
}

/// Full property detail (`PropertyDto`) — superset of [PropertyListItem].
class PropertyDetails {
  const PropertyDetails({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.contractType,
    required this.price,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.status,
    required this.views,
    required this.city,
    required this.district,
    required this.ownerId,
    required this.ownerName,
    required this.description,
    required this.floorsCount,
    required this.ageYears,
    this.address,
    required this.media,
    required this.amenities,
    required this.createdAt,
  });

  final String id;
  final String title;
  final PropertyType propertyType;
  final ContractType contractType;
  final double price;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final PropertyStatus status;
  final int views;
  final String city;
  final String district;
  final String ownerId;
  final String ownerName;
  final String description;
  final int floorsCount;
  final int ageYears;
  final Address? address;
  final List<PropertyMedia> media;
  final List<PropertyAmenity> amenities;
  final DateTime? createdAt;

  bool get acceptsRequests => status.acceptsRequests;

  String get locationLine {
    final parts = [district, city].where((p) => p.trim().isNotEmpty);
    return parts.join('، ');
  }

  /// Ordered image URLs (cover first, then displayOrder).
  List<String> get imageUrls {
    final images = media.where((m) => m.mediaType == 0).toList()
      ..sort((a, b) {
        if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
    return images.map((m) => m.resolvedUrl).toList(growable: false);
  }

  /// Amenities grouped by category for sectioned display.
  Map<AmenityCategory, List<PropertyAmenity>> get amenitiesByCategory {
    final map = <AmenityCategory, List<PropertyAmenity>>{};
    for (final a in amenities) {
      map.putIfAbsent(a.category, () => []).add(a);
    }
    return map;
  }

  factory PropertyDetails.fromJson(Map<String, dynamic> json) =>
      PropertyDetails(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        propertyType:
            PropertyType.fromValue((json['propertyType'] as num?)?.toInt()),
        contractType:
            ContractType.fromValue((json['contractType'] as num?)?.toInt()),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        area: (json['area'] as num?)?.toDouble() ?? 0,
        bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
        bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
        status: PropertyStatus.fromValue((json['status'] as num?)?.toInt()),
        views: (json['views'] as num?)?.toInt() ?? 0,
        city: (json['city'] ?? '').toString(),
        district: (json['district'] ?? '').toString(),
        ownerId: (json['ownerId'] ?? '').toString(),
        ownerName: (json['ownerName'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        floorsCount: (json['floorsCount'] as num?)?.toInt() ?? 0,
        ageYears: (json['ageYears'] as num?)?.toInt() ?? 0,
        address: json['address'] is Map
            ? Address.fromJson((json['address'] as Map).cast<String, dynamic>())
            : null,
        media: ((json['propertyMedia'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PropertyMedia.fromJson)
            .toList(growable: false),
        amenities: ((json['propertyAmenities'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PropertyAmenity.fromJson)
            .toList(growable: false),
        createdAt: _parseDate(json['createdAt']),
      );
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
