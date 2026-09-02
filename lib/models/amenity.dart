import '../core/utils/enums.dart';

/// A single amenity definition (e.g. "مسبح", "موقف سيارات").
class Amenity {
  const Amenity({
    required this.id,
    required this.name,
    required this.category,
    required this.isActive,
  });

  final String id;
  final String name;
  final AmenityCategory category;
  final bool isActive;

  factory Amenity.fromJson(Map<String, dynamic> json) => Amenity(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        category: AmenityCategory.fromValue((json['category'] as num?)?.toInt()),
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Amenities grouped by category, as returned from `GET /api/amenities`.
class AmenityGroup {
  const AmenityGroup({
    required this.category,
    required this.categoryName,
    required this.amenities,
  });

  final AmenityCategory category;
  final String categoryName; // Arabic name from backend
  final List<Amenity> amenities;

  factory AmenityGroup.fromJson(Map<String, dynamic> json) => AmenityGroup(
        category: AmenityCategory.fromValue((json['category'] as num?)?.toInt()),
        categoryName: (json['categoryName'] ?? '').toString(),
        amenities: ((json['amenities'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Amenity.fromJson)
            .toList(growable: false),
      );
}

/// An amenity as attached to a specific property.
class PropertyAmenity {
  const PropertyAmenity({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    required this.category,
  });

  final String id;
  final String amenityId;
  final String amenityName;
  final AmenityCategory category;

  factory PropertyAmenity.fromJson(Map<String, dynamic> json) =>
      PropertyAmenity(
        id: (json['id'] ?? '').toString(),
        amenityId: (json['amenityId'] ?? '').toString(),
        amenityName: (json['amenityName'] ?? '').toString(),
        category: AmenityCategory.fromValue((json['category'] as num?)?.toInt()),
      );
}
