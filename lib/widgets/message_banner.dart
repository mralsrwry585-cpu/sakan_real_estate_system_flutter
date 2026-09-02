import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

enum BannerTone { error, warning, info, success }

/// A soft, tinted inline banner (icon + message) for form errors and notices.
class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.error,
    this.icon,
  });

  final String message;
  final BannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color color, IconData defaultIcon) = switch (tone) {
      BannerTone.error => (c.destructive, Icons.error_outline_rounded),
      BannerTone.warning => (c.warning, Icons.warning_amber_rounded),
      BannerTone.info => (c.info, Icons.info_outline_rounded),
      BannerTone.success => (c.success, Icons.check_circle_outline_rounded),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.tint(0.10),
        borderRadius: AppRadius.brLg,
        border: Border.all(color: color.tint(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
