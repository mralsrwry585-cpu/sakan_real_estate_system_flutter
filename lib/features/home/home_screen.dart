import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../models/property.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/property_card.dart';
import '../../widgets/section_header.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_controller.dart';
import '../shell/main_shell.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(featuredPropertiesProvider);
    ref.invalidate(latestPropertiesProvider);
    await Future.wait([
      ref.read(featuredPropertiesProvider.future),
      ref.read(latestPropertiesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredPropertiesProvider);
    final latest = ref.watch(latestPropertiesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _HomeHeader(),
            const SizedBox(height: 8),
            _FeaturedSection(featured: featured),
            const SizedBox(height: 8),
            _LatestSection(latest: latest),
            const SizedBox(height: kBottomNavSpace),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final unread = ref.watch(unreadNotificationsCountProvider);
    final greetingName = (user?.firstName ?? '').trim();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderCircleButton(
                icon: Icons.menu_rounded,
                onTap: openAppDrawer,
                tooltip: S.settings,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.homeGreeting,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.tint(0.85),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greetingName.isEmpty ? S.appName : greetingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              _BellButton(unread: unread),
            ],
          ),
          const SizedBox(height: 18),
          _SearchTapBar(onTap: () => context.go(Routes.search)),
        ],
      ),
    );
  }
}

/// A translucent circular button used in the hero header (menu / actions).
class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.tint(0.16),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread});

  final int unread;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: Colors.white.tint(0.16),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.notifications),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 24),
              if (unread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: c.destructive,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTapBar extends StatelessWidget {
  const _SearchTapBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: AppRadius.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: c.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.searchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: c.mutedForeground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection({required this.featured});

  final AsyncValue<List<PropertyListItem>> featured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return featured.when(
      loading: () => const _FeaturedRailSkeleton(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InlineError(
          message: S.somethingWentWrong,
          onRetry: () => ref.invalidate(featuredPropertiesProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SectionHeader(title: S.featured),
            ),
            SizedBox(
              height: 322,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => PropertyCard(
                  property: items[i],
                  variant: PropertyCardVariant.featured,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeaturedRailSkeleton extends StatelessWidget {
  const _FeaturedRailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 322,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => const SizedBox(
          width: 280,
          child: PropertyCardSkeleton(),
        ),
      ),
    );
  }
}

class _LatestSection extends ConsumerWidget {
  const _LatestSection({required this.latest});

  final AsyncValue<List<PropertyListItem>> latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: S.latest,
            onSeeAll: () => context.go(Routes.search),
          ),
          const SizedBox(height: 4),
          latest.when(
            loading: () => const PropertyListSkeleton(count: 3),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(latestPropertiesProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EmptyState(
                    icon: Icons.home_work_outlined,
                    title: S.emptyProperties,
                    message: S.emptyPropertiesHint,
                  ),
                );
              }
              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => PropertyCard(property: items[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}
