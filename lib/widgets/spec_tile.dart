import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

/// A compact spec chip: icon + value (+ optional label). Used for
/// bedrooms/bathrooms/area on cards and detail pages.
class SpecTile extends StatelessWidget {
  const SpecTile({
    super.key,
    required this.icon,
    required this.value,
    this.label,
    this.filled = false,
  });

  final IconData icon;
  final String value;
  final String? label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? c.secondary : c.surface2,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (label != null) ...[
            const SizedBox(width: 3),
            Text(
              label!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: c.mutedForeground),
            ),
          ],
        ],
      ),
    );
  }
}

/// A larger stat block for the detail page (icon on top, value, caption).
class SpecStat extends StatelessWidget {
  const SpecStat({
    super.key,
    required this.icon,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: c.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.mutedForeground),
          ),
        ],
      ),
    );
  }
}
