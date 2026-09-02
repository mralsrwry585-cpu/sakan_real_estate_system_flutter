import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/property_card.dart';
import '../shell/main_shell.dart';
import 'filter_sheet.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Kick off the first load once the first frame is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(propertySearchProvider.notifier);
      _searchController.text =
          ref.read(propertySearchProvider).filter.searchTerm ?? '';
      notifier.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(propertySearchProvider.notifier).loadMore();
    }
  }

  Future<void> _openFilters() async {
    final current = ref.read(propertySearchProvider).filter;
    final result = await FilterSheet.show(context, current);
    if (result != null) {
      ref.read(propertySearchProvider.notifier).applyFilter(result);
    }
  }

  Future<void> _openSort() async {
    final current = ref.read(propertySearchProvider).filter.sort;
    final selected = await showModalBottomSheet<PropertySort>(
      context: context,
      builder: (_) => _SortSheet(selected: current),
    );
    if (selected != null) {
      ref.read(propertySearchProvider.notifier).setSort(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertySearchProvider);
    final notifier = ref.read(propertySearchProvider.notifier);
    final activeCount = state.filter.activeFilterCount;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(
              controller: _searchController,
              activeFilterCount: activeCount,
              onSubmitted: notifier.setSearchTerm,
              onClear: () {
                _searchController.clear();
                notifier.setSearchTerm('');
              },
              onFilter: _openFilters,
              onSort: _openSort,
            ),
            if (state.status == SearchStatus.loading && state.items.isNotEmpty)
              const LinearProgressIndicator(minHeight: 2),
            if (state.status == SearchStatus.ready && state.items.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    '${Fmt.number(state.totalCount)} ${S.results}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            Expanded(child: _buildResults(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchState state, PropertySearchController notifier) {
    if (state.items.isEmpty) {
      switch (state.status) {
        case SearchStatus.initial:
        case SearchStatus.loading:
          return const PropertyListSkeleton(count: 4);
        case SearchStatus.error:
          return ErrorView(error: state.error, onRetry: notifier.retry);
        case SearchStatus.ready:
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: S.emptyProperties,
            message: S.emptyPropertiesHint,
            actionLabel: state.filter.hasActiveFilters ? S.resetFilters : null,
            onAction: state.filter.hasActiveFilters ? notifier.reset : null,
          );
      }
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavSpace),
        itemCount: state.items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox(height: 8);
          }
          return PropertyCard(property: state.items[index]);
        },
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.activeFilterCount,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilter,
    required this.onSort,
  });

  final TextEditingController controller;
  final int activeFilterCount;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _IconAction(icon: Icons.menu_rounded, onTap: openAppDrawer),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: S.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: onClear,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.tune_rounded,
            badge: activeFilterCount > 0 ? '$activeFilterCount' : null,
            onTap: onFilter,
          ),
          const SizedBox(width: 8),
          _IconAction(icon: Icons.swap_vert_rounded, onTap: onSort),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap, this.badge});

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: c.surface,
          borderRadius: AppRadius.brLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: AppRadius.brLg,
                border: Border.all(color: c.border),
              ),
              child: Icon(icon, color: c.primary),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 1.5),
              ),
              child: Text(
                badge!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.primaryForeground,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected});

  final PropertySort selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(S.sortBy,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          const Divider(height: 1),
          for (final sort in PropertySort.values)
            ListTile(
              title: Text(sort.label),
              trailing: sort == selected
                  ? Icon(Icons.check_circle_rounded, color: c.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(sort),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
