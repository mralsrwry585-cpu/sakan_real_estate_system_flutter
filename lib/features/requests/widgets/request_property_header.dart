import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/property.dart';
import '../../../widgets/app_network_image.dart';

/// Compact property summary shown atop the viewing/booking request forms so the
/// tenant always sees which property they're requesting.
class RequestPropertyHeader extends StatelessWidget {
  const RequestPropertyHeader({super.key, required this.property});

  final PropertyDetails property;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final cover = property.imageUrls.isEmpty ? null : property.imageUrls.first;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.brMd,
            child: SizedBox(
              width: 68,
              height: 68,
              child: AppNetworkImage(
                url: cover,
                propertyType: property.propertyType,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  property.locationLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: c.mutedForeground),
                ),
                const SizedBox(height: 4),
                Text(
                  Fmt.priceWithContract(property.price, property.contractType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
