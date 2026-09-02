import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/status_ui.dart';
import '../../models/property.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/spec_tile.dart';
import '../../widgets/status_pill.dart';
import '../favorites/favorites_controller.dart';
import 'property_details_provider.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  const PropertyDetailsScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(propertyDetailsProvider(propertyId));

    return Scaffold(
      body: async.when(
        loading: () => const _DetailsScaffoldShell(child: LoadingIndicator()),
        error: (e, _) => _DetailsScaffoldShell(
          child: ErrorView(
            error: e,
            onRetry: () =>
                ref.invalidate(propertyDetailsProvider(propertyId)),
          ),
        ),
        data: (property) => _DetailsBody(property: property),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (property) => _ActionBar(property: property),
        orElse: () => null,
      ),
    );
  }
}

/// Minimal scaffold (just a back button) for the loading/error states.
class _DetailsScaffoldShell extends StatelessWidget {
  const _DetailsScaffoldShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _pop(context),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

void _pop(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({required this.property});

  final PropertyDetails property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(property.id)),
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: c.surface,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => _pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor: isFavorite ? c.destructive : null,
                onTap: () =>
                    ref.read(favoritesProvider.notifier).toggle(property.id),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _ImageGallery(
              images: property.imageUrls,
              propertyType: property.propertyType,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ContractChip(contract: property.contractType),
                    const Spacer(),
                    StatusPill(
                      visual: StatusUi.property(property.status, c),
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(property.title, style: text.headlineMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 18, color: c.mutedForeground),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.locationLine,
                        style: text.bodyMedium
                            ?.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.price(property.price),
                      style: text.displaySmall?.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    if (property.contractType.priceSuffix.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          property.contractType.priceSuffix,
                          style: text.bodyMedium
                              ?.copyWith(color: c.mutedForeground),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _specStats(context),
                if (property.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(context, S.description),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: text.bodyLarge?.copyWith(height: 1.7),
                  ),
                ],
                if (property.amenities.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(context, S.amenities),
                  const SizedBox(height: 12),
                  _amenities(context),
                ],
                const SizedBox(height: 24),
                _sectionTitle(context, S.location),
                const SizedBox(height: 12),
                _locationCard(context),
                const SizedBox(height: 24),
                _sectionTitle(context, S.owner),
                const SizedBox(height: 12),
                _ownerCard(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _specStats(BuildContext context) {
    final hasRooms = property.propertyType != PropertyType.land;
    final stats = <Widget>[
      if (hasRooms)
        Expanded(
          child: SpecStat(
            icon: Icons.king_bed_outlined,
            value: '${property.bedrooms}',
            caption: S.rooms,
          ),
        ),
      if (hasRooms)
        Expanded(
          child: SpecStat(
            icon: Icons.bathtub_outlined,
            value: '${property.bathrooms}',
            caption: S.baths,
          ),
        ),
      Expanded(
        child: SpecStat(
          icon: Icons.straighten_outlined,
          value: Fmt.number(property.area),
          caption: S.areaUnit,
        ),
      ),
      if (property.floorsCount > 0)
        Expanded(
          child: SpecStat(
            icon: Icons.stairs_outlined,
            value: '${property.floorsCount}',
            caption: S.floors,
          ),
        ),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          stats[i],
        ],
      ],
    );
  }

  Widget _amenities(BuildContext context) {
    final grouped = property.amenitiesByCategory;
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(
              entry.key.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: c.mutedForeground,
                  ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in entry.value)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.secondary,
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, size: 15, color: c.primary),
                      const SizedBox(width: 5),
                      Text(
                        a.amenityName,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _locationCard(BuildContext context) {
    final c = context.colors;
    final address = property.address;
    final line = address?.shortLine.trim();
    final display = (line != null && line.isNotEmpty)
        ? '$line، ${property.city}'
        : property.locationLine;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: AppRadius.brLg,
      ),
      child: Row(
        children: [
          Icon(Icons.map_outlined, color: c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              display,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (address != null && address.hasCoordinates)
            TextButton.icon(
              onPressed: () => _openMap(address.latitude, address.longitude),
              icon: const Icon(Icons.directions_outlined, size: 18),
              label: const Text(S.showOnMap),
            ),
        ],
      ),
    );
  }

  Widget _ownerCard(BuildContext context) {
    final c = context.colors;
    final name = property.ownerName.trim();
    final initial = name.isEmpty ? '؟' : name.substring(0, 1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: AppRadius.brLg,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppGradients.gold,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                color: c.goldForeground,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.owner, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                name.isEmpty ? '—' : name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      );

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.property});

  final PropertyDetails property;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (!property.acceptsRequests) {
      return SafeArea(
        minimum: const EdgeInsets.all(16),
        child: const MessageBanner(
          message: S.notAvailableForRequests,
          tone: BannerTone.warning,
        ),
      );
    }

    final showBooking = property.contractType != ContractType.sale;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: S.requestViewing,
                icon: Icons.event_available_outlined,
                variant: showBooking
                    ? AppButtonVariant.outline
                    : AppButtonVariant.primary,
                onPressed: () => context.push(
                  Routes.viewingRequest(property.id),
                  extra: property,
                ),
              ),
            ),
            if (showBooking) ...[
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: S.requestBooking,
                  icon: Icons.vpn_key_outlined,
                  onPressed: () => context.push(
                    Routes.bookingRequest(property.id),
                    extra: property,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContractChip extends StatelessWidget {
  const _ContractChip({required this.contract});

  final ContractType contract;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: AppRadius.brFull,
      ),
      child: Text(
        contract.label,
        style: TextStyle(
          color: c.primaryForeground,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface.tint(0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: iconColor ?? c.foreground, size: 22),
        ),
      ),
    );
  }
}

/// A swipeable image gallery with page dots and an index counter.
class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.images, required this.propertyType});

  final List<String> images;
  final PropertyType propertyType;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) {
      return AppNetworkImage(url: null, propertyType: widget.propertyType);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => AppNetworkImage(
            url: images[i],
            propertyType: widget.propertyType,
          ),
        ),
        // Scrim so the pinned back/favorite buttons stay legible.
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black.tint(0.28), Colors.transparent],
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Colors.white
                          : Colors.white.tint(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
