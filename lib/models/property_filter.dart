import '../core/config/app_config.dart';
import '../core/utils/enums.dart';

/// Immutable set of filters/sort/paging for `GET /api/properties`.
///
/// Enums are sent as **PascalCase names** in the query string (per the backend
/// contract); `sortBy` is a lowercase token. Only non-null fields are emitted.
class PropertyFilter {
  const PropertyFilter({
    this.pageNumber = 1,
    this.pageSize = AppConfig.pageSize,
    this.searchTerm,
    this.propertyType,
    this.contractType,
    this.status = PropertyStatus.available,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.maxBedrooms,
    this.city,
    this.district,
    this.sort = PropertySort.newest,
  });

  final int pageNumber;
  final int pageSize;
  final String? searchTerm;
  final PropertyType? propertyType;
  final ContractType? contractType;

  /// Tenants browse only Available properties by default.
  final PropertyStatus? status;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? maxBedrooms;
  final String? city;
  final String? district;
  final PropertySort sort;

  /// True when any user-facing filter (not paging/sort/status) is active.
  bool get hasActiveFilters =>
      (searchTerm?.trim().isNotEmpty ?? false) ||
      propertyType != null ||
      contractType != null ||
      minPrice != null ||
      maxPrice != null ||
      minBedrooms != null ||
      maxBedrooms != null ||
      (city?.trim().isNotEmpty ?? false) ||
      (district?.trim().isNotEmpty ?? false);

  /// Count of active filter facets, for a badge on the filter button.
  int get activeFilterCount {
    var n = 0;
    if (propertyType != null) n++;
    if (contractType != null) n++;
    if (minPrice != null || maxPrice != null) n++;
    if (minBedrooms != null) n++;
    if (maxBedrooms != null) n++;
    if (city?.trim().isNotEmpty ?? false) n++;
    if (district?.trim().isNotEmpty ?? false) n++;
    return n;
  }

  Map<String, dynamic> toQueryParameters() {
    final q = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sortBy': sort.sortBy,
      'sortAscending': sort.ascending,
    };
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      q[key] = value;
    }

    put('searchTerm', searchTerm?.trim());
    put('propertyType', propertyType?.apiName);
    put('contractType', contractType?.apiName);
    put('status', status?.apiName);
    put('minPrice', minPrice);
    put('maxPrice', maxPrice);
    put('minBedrooms', minBedrooms);
    put('maxBedrooms', maxBedrooms);
    put('city', city?.trim());
    put('district', district?.trim());
    return q;
  }

  PropertyFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? Function()? searchTerm,
    PropertyType? Function()? propertyType,
    ContractType? Function()? contractType,
    PropertyStatus? Function()? status,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    int? Function()? minBedrooms,
    int? Function()? maxBedrooms,
    String? Function()? city,
    String? Function()? district,
    PropertySort? sort,
  }) {
    return PropertyFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm != null ? searchTerm() : this.searchTerm,
      propertyType: propertyType != null ? propertyType() : this.propertyType,
      contractType: contractType != null ? contractType() : this.contractType,
      status: status != null ? status() : this.status,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      minBedrooms: minBedrooms != null ? minBedrooms() : this.minBedrooms,
      maxBedrooms: maxBedrooms != null ? maxBedrooms() : this.maxBedrooms,
      city: city != null ? city() : this.city,
      district: district != null ? district() : this.district,
      sort: sort ?? this.sort,
    );
  }

  /// Resets all facets but keeps the search term and sort.
  PropertyFilter cleared() => PropertyFilter(
        pageSize: pageSize,
        searchTerm: searchTerm,
        status: status,
        sort: sort,
      );
}
