/// Generic pagination envelope returned by list endpoints.
///
/// The backend response always uses `pageNumber` in the body (even for the
/// requests endpoints whose *query* param is `page`).
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  bool get isEmpty => items.isEmpty;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    return PagedResult<T>(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(fromItem)
          .toList(growable: false),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? rawItems.length,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? rawItems.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  /// Empty result, useful as an initial/placeholder value.
  static PagedResult<T> empty<T>() => PagedResult<T>(
        items: const [],
        totalCount: 0,
        pageNumber: 1,
        pageSize: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );
}
