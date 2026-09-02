import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// A tappable field row (icon + label + selected value + chevron) used for the
/// date/time pickers on the request forms. Renders an inline error underneath
/// when [error] is provided.
class RequestFieldTile extends StatelessWidget {
  const RequestFieldTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.filled = false,
    this.error,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  /// When true the value has been chosen (stronger text, primary border).
  final bool filled;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final borderColor = error != null
        ? c.destructive
        : filled
            ? c.primary
            : c.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: c.surface,
          borderRadius: AppRadius.brLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: AppRadius.brLg,
                border: Border.all(
                  color: borderColor,
                  width: filled || error != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: c.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: text.bodySmall
                              ?.copyWith(color: c.mutedForeground),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: text.titleMedium?.copyWith(
                            fontWeight:
                                filled ? FontWeight.w800 : FontWeight.w500,
                            color: filled ? c.foreground : c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: c.mutedForeground),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              error!,
              style: text.bodySmall?.copyWith(color: c.destructive),
            ),
          ),
      ],
    );
  }
}
