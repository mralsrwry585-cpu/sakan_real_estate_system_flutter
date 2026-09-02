import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/enums.dart';
import '../../data/repositories/property_repository.dart';
import '../../models/property.dart';
import '../../models/property_filter.dart';
import '../../providers/app_providers.dart';

enum SearchStatus { initial, loading, ready, error }

/// Immutable state for the Search screen: the active filter, the accumulated
/// result list (across pages), the load phase, and pagination flags.
class SearchState {
  const SearchState({
    this.filter = const PropertyFilter(),
    this.items = const [],
    this.status = SearchStatus.initial,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = false,
    this.totalCount = 0,
  });

  final PropertyFilter filter;
  final List<PropertyListItem> items;
  final SearchStatus status;
  final bool isLoadingMore;
  final Object? error;
  final bool hasMore;
  final int totalCount;

  bool get isEmpty => status == SearchStatus.ready && items.isEmpty;

  SearchState copyWith({
    PropertyFilter? filter,
    List<PropertyListItem>? items,
    SearchStatus? status,
    bool? isLoadingMore,
    Object? Function()? error,
    bool? hasMore,
    int? totalCount,
  }) {
    return SearchState(
      filter: filter ?? this.filter,
      items: items ?? this.items,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error != null ? error() : this.error,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Owns paginated property search: search term, facet filters, sort, and
/// infinite scroll. Named `PropertySearchController` to avoid clashing with
/// Material's `SearchController`.
class PropertySearchController extends StateNotifier<SearchState> {
  PropertySearchController(this._repo) : super(const SearchState());

  final PropertyRepository _repo;

  /// Triggers the first load if nothing has been fetched yet.
  Future<void> ensureLoaded() async {
    if (state.status == SearchStatus.initial) await _reload();
  }

  Future<void> setSearchTerm(String term) async {
    final trimmed = term.trim();
    state = state.copyWith(
      filter: state.filter.copyWith(
        searchTerm: () => trimmed.isEmpty ? null : trimmed,
        pageNumber: 1,
      ),
    );
    await _reload();
  }

  Future<void> applyFilter(PropertyFilter filter) async {
    state = state.copyWith(filter: filter.copyWith(pageNumber: 1));
    await _reload();
  }

  Future<void> setSort(PropertySort sort) async {
    state = state.copyWith(filter: state.filter.copyWith(sort: sort, pageNumber: 1));
    await _reload();
  }

  Future<void> reset() async {
    state = state.copyWith(filter: state.filter.cleared().copyWith(pageNumber: 1));
    await _reload();
  }

  Future<void> retry() => _reload();

  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    state = state.copyWith(status: SearchStatus.loading, error: () => null);
    try {
      final result =
          await _repo.getProperties(state.filter.copyWith(pageNumber: 1));
      state = state.copyWith(
        items: result.items,
        status: SearchStatus.ready,
        hasMore: result.hasNextPage,
        totalCount: result.totalCount,
        filter: state.filter.copyWith(pageNumber: 1),
      );
    } catch (e) {
      state = state.copyWith(status: SearchStatus.error, error: () => e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != SearchStatus.ready) {
      return;
    }
    final nextPage = state.filter.pageNumber + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result =
          await _repo.getProperties(state.filter.copyWith(pageNumber: nextPage));
      state = state.copyWith(
        items: [...state.items, ...result.items],
        filter: state.filter.copyWith(pageNumber: nextPage),
        hasMore: result.hasNextPage,
        totalCount: result.totalCount,
        isLoadingMore: false,
      );
    } catch (_) {
      // Keep the existing page; surface a lightweight failure only.
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final propertySearchProvider =
    StateNotifierProvider<PropertySearchController, SearchState>(
  (ref) => PropertySearchController(ref.watch(propertyRepositoryProvider)),
);
