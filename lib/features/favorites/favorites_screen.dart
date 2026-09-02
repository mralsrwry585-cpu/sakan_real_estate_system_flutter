import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/property_card.dart';
import '../shell/main_shell.dart';
import 'favorite_properties_provider.dart';
import 'favorites_controller.dart';

/// Favorites tab. The property data is loaded once; the visible set is filtered
/// live against [favoritesProvider], so un-favoriting removes a card instantly
/// without a refetch.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoritePropertiesProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppDrawerButton(),
        title: const Text(S.favorites),
      ),
      body: async.when(
        loading: () => const PropertyListSkeleton(count: 4),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(favoritePropertiesProvider),
        ),
        data: (loaded) {
          // Keep only still-favorited items, preserving load order.
          final items =
              loaded.where((p) => favoriteIds.contains(p.id)).toList();

          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: S.emptyFavorites,
              message: S.emptyFavoritesHint,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritePropertiesProvider);
              await ref.read(favoritePropertiesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavSpace),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => PropertyCard(property: items[i]),
            ),
          );
        },
      ),
    );
  }
}
