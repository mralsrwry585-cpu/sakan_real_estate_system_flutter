import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';

/// A rounded surface with the SAKAN card shadow. Optionally tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppRadius.brXl,
    this.shadow = true,
    this.border = false,
    this.color,
    this.clip = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool shadow;
  final bool border;
  final Color? color;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final surface = Container(
      decoration: BoxDecoration(
        color: color ?? c.card,
        borderRadius: borderRadius,
        boxShadow: shadow ? AppShadows.card : null,
        border: border ? Border.all(color: c.border) : null,
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: surface),
    );
  }
}
