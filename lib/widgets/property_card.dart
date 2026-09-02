import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/app_radius.dart';
import '../core/utils/enums.dart';
import '../core/utils/formatters.dart';
import '../core/utils/status_ui.dart';
import '../features/favorites/favorites_controller.dart';
import '../models/property.dart';
import 'app_card.dart';
import 'app_network_image.dart';
import 'status_pill.dart';

/// Layout variants for [PropertyCard].
enum PropertyCardVariant {
  /// Fixed-width card for the horizontal "featured" rail on Home.
  featured,

  /// Full-width card for vertical lists (Search, Favorites, "latest").
  list,
}

/// The SAKAN property card — reproduces the Lovable listing card with a cover
/// image, contract badge, favorite heart, price, location and spec chips.
///
/// A [ConsumerWidget] so the heart reflects [favoritesProvider] instantly and
/// toggles it in place. Tapping the card opens the details route unless an
/// [onTap] override is supplied.
class PropertyCard extends ConsumerWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.variant = PropertyCardVariant.list,
    this.onTap,
    this.width,
  });

  final PropertyListItem property;
  final PropertyCardVariant variant;
  final VoidCallback? onTap;

  /// Width for the [PropertyCardVariant.featured] variant (ignored for list).
  final double? width;

  bool get _isFeatured => variant == PropertyCardVariant.featured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(property.id)),
    );
    final imageHeight = _isFeatured ? 148.0 : 178.0;

    final card = AppCard(
      onTap: onTap ?? () => context.push(Routes.propertyDetails(property.id)),
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _cover(context, ref, c, imageHeight, isFavorite),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: _details(context, c),
          ),
        ],
      ),
    );

    if (_isFeatured) {
      return SizedBox(width: width ?? 280, child: card);
    }
    return card;
  }

  // ─────────────────────────────────────────── cover + overlays
  Widget _cover(
    BuildContext context,
    WidgetRef ref,
    SakanColors c,
    double height,
    bool isFavorite,
  ) {
    final showStatus = property.status != PropertyStatus.available;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: property.resolvedCoverUrl,
            propertyType: property.propertyType,
          ),
          // Subtle top gradient so white overlays stay legible on any photo.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black.tint(0.28), Colors.transparent],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _contractBadge(context, c),
                      const Spacer(),
                      _favoriteButton(context, ref, c, isFavorite),
                    ],
                  ),
                  const Spacer(),
                  if (showStatus)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StatusPill(
                        visual: StatusUi.property(property.status, c),
                        compact: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractBadge(BuildContext context, SakanColors c) {
    final isSale = property.contractType == ContractType.sale;
    final gradient = isSale ? AppGradients.gold : AppGradients.primary(c);
    final fg = isSale ? c.goldForeground : c.primaryForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.brFull,
      ),
      child: Text(
        property.contractType.label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _favoriteButton(
    BuildContext context,
    WidgetRef ref,
    SakanColors c,
    bool isFavorite,
  ) {
    return Material(
      color: Colors.white.tint(0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ref.read(favoritesProvider.notifier).toggle(property.id),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 20,
            color: isFavorite ? c.destructive : c.mutedForeground,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────── text + specs
  Widget _details(BuildContext context, SakanColors c) {
    final text = Theme.of(context).textTheme;
    final suffix = property.contractType.priceSuffix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 15, color: c.mutedForeground),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                property.locationLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: c.mutedForeground),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                Fmt.price(property.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge?.copyWith(
                  color: c.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (suffix.isNotEmpty) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: text.bodySmall?.copyWith(color: c.mutedForeground),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _specs(context),
      ],
    );
  }

  Widget _specs(BuildContext context) {
    final hasRooms = property.propertyType != PropertyType.land;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasRooms)
          SpecChip(icon: Icons.king_bed_outlined, value: '${property.bedrooms}'),
        if (hasRooms)
          SpecChip(
            icon: Icons.bathtub_outlined,
            value: '${property.bathrooms}',
          ),
        SpecChip(
          icon: Icons.straighten_outlined,
          value: Fmt.area(property.area),
        ),
      ],
    );
  }
}

/// A compact icon + value chip used inside [PropertyCard]'s spec row.
///
/// (Kept local and lighter than the shared `SpecTile` so several fit within a
/// narrow featured card.)
class SpecChip extends StatelessWidget {
  const SpecChip({super.key, required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: c.primary),
          const SizedBox(width: 5),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
