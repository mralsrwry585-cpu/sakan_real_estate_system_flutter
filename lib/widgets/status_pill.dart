import 'package:flutter/material.dart';

import '../core/theme/app_radius.dart';
import '../core/utils/status_ui.dart';

/// A soft, rounded status chip (icon + label) built from a [StatusVisual].
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.visual, this.compact = false});

  final StatusVisual visual;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: AppRadius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: compact ? 13 : 15, color: visual.color),
          const SizedBox(width: 5),
          Text(
            visual.label,
            style: TextStyle(
              color: visual.color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
