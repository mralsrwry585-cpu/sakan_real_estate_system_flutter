import 'package:flutter/material.dart';

/// Domain enums mirrored from the backend.
///
/// Serialization rules (per the backend contract):
///  - In JSON request/response bodies, enums are **integers** → use [value].
///  - In query strings, enums are **PascalCase names** → use [apiName].
///  - [label] is the Arabic display string.
///
/// All `fromValue` factories tolerate unknown ints by falling back to a safe
/// default, so a new backend enum member never crashes the app.

// ─────────────────────────────────────────── Role
enum UserRole {
  tenant(0, 'Tenant', 'مستأجر'),
  owner(1, 'Owner', 'مالك');

  const UserRole(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static UserRole fromValue(int? v) =>
      UserRole.values.firstWhere((e) => e.value == v,
          orElse: () => UserRole.tenant);
}

// ─────────────────────────────────────────── Property type
enum PropertyType {
  land(0, 'Land', 'أرض'),
  apartment(1, 'Apartment', 'شقة'),
  independentHouse(2, 'IndependentHouse', 'بيت مستقل'),
  villa(3, 'Villa', 'فيلا'),
  commercial(4, 'Commercial', 'تجاري'),
  office(5, 'Office', 'مكتب'),
  studio(6, 'Studio', 'استوديو'),
  duplex(7, 'Duplex', 'دوبلكس');

  const PropertyType(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static PropertyType fromValue(int? v) =>
      PropertyType.values.firstWhere((e) => e.value == v,
          orElse: () => PropertyType.apartment);

  IconData get icon {
    switch (this) {
      case PropertyType.land:
        return Icons.terrain_outlined;
      case PropertyType.apartment:
        return Icons.apartment_outlined;
      case PropertyType.independentHouse:
        return Icons.house_outlined;
      case PropertyType.villa:
        return Icons.villa_outlined;
      case PropertyType.commercial:
        return Icons.storefront_outlined;
      case PropertyType.office:
        return Icons.business_outlined;
      case PropertyType.studio:
        return Icons.meeting_room_outlined;
      case PropertyType.duplex:
        return Icons.maps_home_work_outlined;
    }
  }
}

// ─────────────────────────────────────────── Contract type
enum ContractType {
  sale(0, 'Sale', 'بيع'),
  rent(1, 'Rent', 'إيجار'),
  dailyRent(2, 'DailyRent', 'إيجار يومي');

  const ContractType(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static ContractType fromValue(int? v) =>
      ContractType.values.firstWhere((e) => e.value == v,
          orElse: () => ContractType.rent);

  /// Price suffix, e.g. "ر.س / شهرياً".
  String get priceSuffix {
    switch (this) {
      case ContractType.sale:
        return '';
      case ContractType.rent:
        return '/ شهرياً';
      case ContractType.dailyRent:
        return '/ يومياً';
    }
  }
}

// ─────────────────────────────────────────── Property status
enum PropertyStatus {
  draft(0, 'Draft', 'مسودة'),
  pendingApproval(1, 'PendingApproval', 'قيد المراجعة'),
  available(2, 'Available', 'متاح'),
  reserved(3, 'Reserved', 'محجوز'),
  sold(4, 'Sold', 'مباع'),
  rented(5, 'Rented', 'مؤجّر'),
  hidden(6, 'Hidden', 'مخفي');

  const PropertyStatus(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static PropertyStatus fromValue(int? v) =>
      PropertyStatus.values.firstWhere((e) => e.value == v,
          orElse: () => PropertyStatus.draft);

  /// Only Available properties accept viewing/booking requests.
  bool get acceptsRequests => this == PropertyStatus.available;
}

// ─────────────────────────────────────────── Booking status
enum BookingStatus {
  pending(0, 'Pending', 'قيد الانتظار'),
  approved(1, 'Approved', 'مقبول'),
  rejected(2, 'Rejected', 'مرفوض'),
  cancelled(3, 'Cancelled', 'ملغى'),
  completed(4, 'Completed', 'مكتمل');

  const BookingStatus(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static BookingStatus fromValue(int? v) =>
      BookingStatus.values.firstWhere((e) => e.value == v,
          orElse: () => BookingStatus.pending);
}

// ─────────────────────────────────────────── Viewing status
enum ViewingStatus {
  pending(0, 'Pending', 'قيد الانتظار'),
  approved(1, 'Approved', 'مقبول'),
  rejected(2, 'Rejected', 'مرفوض'),
  completed(3, 'Completed', 'مكتمل'),
  cancelled(4, 'Cancelled', 'ملغى');

  const ViewingStatus(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static ViewingStatus fromValue(int? v) =>
      ViewingStatus.values.firstWhere((e) => e.value == v,
          orElse: () => ViewingStatus.pending);
}

// ─────────────────────────────────────────── Amenity category
enum AmenityCategory {
  interior(0, 'Interior', 'داخلي'),
  exterior(1, 'Exterior', 'خارجي'),
  services(2, 'Services', 'خدمات'),
  security(3, 'Security', 'أمان'),
  technology(4, 'Technology', 'تقنية');

  const AmenityCategory(this.value, this.apiName, this.label);
  final int value;
  final String apiName;
  final String label;

  static AmenityCategory fromValue(int? v) =>
      AmenityCategory.values.firstWhere((e) => e.value == v,
          orElse: () => AmenityCategory.services);
}

// ─────────────────────────────────────────── Property sort
enum PropertySort {
  newest('createdat', false, 'الأحدث'),
  priceLow('price', true, 'السعر: الأقل'),
  priceHigh('price', false, 'السعر: الأعلى'),
  areaLarge('area', false, 'المساحة: الأكبر'),
  mostViewed('views', false, 'الأكثر مشاهدة');

  const PropertySort(this.sortBy, this.ascending, this.label);
  final String sortBy;
  final bool ascending;
  final String label;
}
