import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'enums.dart';

/// The visual treatment (color, soft background, icon, label) for a status pill.
class StatusVisual {
  const StatusVisual({
    required this.color,
    required this.background,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color background;
  final IconData icon;
  final String label;
}

/// Maps domain statuses to their pill visuals using the active palette.
class StatusUi {
  const StatusUi._();

  static StatusVisual _make(Color c, IconData icon, String label) =>
      StatusVisual(color: c, background: c.tint(0.12), icon: icon, label: label);

  static StatusVisual viewing(ViewingStatus status, SakanColors c) {
    switch (status) {
      case ViewingStatus.pending:
        return _make(c.warning, Icons.schedule_rounded, status.label);
      case ViewingStatus.approved:
        return _make(c.success, Icons.check_circle_rounded, status.label);
      case ViewingStatus.rejected:
        return _make(c.destructive, Icons.cancel_rounded, status.label);
      case ViewingStatus.completed:
        return _make(c.info, Icons.task_alt_rounded, status.label);
      case ViewingStatus.cancelled:
        return _make(c.mutedForeground, Icons.block_rounded, status.label);
    }
  }

  static StatusVisual booking(BookingStatus status, SakanColors c) {
    switch (status) {
      case BookingStatus.pending:
        return _make(c.warning, Icons.schedule_rounded, status.label);
      case BookingStatus.approved:
        return _make(c.success, Icons.check_circle_rounded, status.label);
      case BookingStatus.rejected:
        return _make(c.destructive, Icons.cancel_rounded, status.label);
      case BookingStatus.completed:
        return _make(c.info, Icons.task_alt_rounded, status.label);
      case BookingStatus.cancelled:
        return _make(c.mutedForeground, Icons.block_rounded, status.label);
    }
  }

  static StatusVisual property(PropertyStatus status, SakanColors c) {
    switch (status) {
      case PropertyStatus.available:
        return _make(c.success, Icons.check_circle_rounded, status.label);
      case PropertyStatus.reserved:
        return _make(c.warning, Icons.lock_clock_rounded, status.label);
      case PropertyStatus.rented:
      case PropertyStatus.sold:
        return _make(c.info, Icons.verified_rounded, status.label);
      case PropertyStatus.draft:
      case PropertyStatus.pendingApproval:
      case PropertyStatus.hidden:
        return _make(c.mutedForeground, Icons.visibility_off_rounded,
            status.label);
    }
  }
}
