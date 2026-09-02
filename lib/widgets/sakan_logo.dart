import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/app_shadows.dart';

/// The SAKAN logo mark: the glyph "س" inside a gradient rounded box, with an
/// optional app name and tagline beneath.
class SakanLogo extends StatelessWidget {
  const SakanLogo({
    super.key,
    this.size = 72,
    this.showName = true,
    this.showTagline = false,
    this.onDark = false,
  });

  final double size;
  final bool showName;
  final bool showTagline;

  /// When placed on a dark hero background, render name/tagline in light ink.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final nameColor = onDark ? Colors.white : c.foreground;
    final taglineColor =
        onDark ? Colors.white.tint(0.85) : c.mutedForeground;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppGradients.primary(c),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: AppShadows.elegant(c),
          ),
          alignment: Alignment.center,
          child: Text(
            'س',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w800,
              fontSize: size * 0.5,
              color: c.primaryForeground,
              height: 1,
            ),
          ),
        ),
        if (showName) ...[
          SizedBox(height: size * 0.22),
          Text(
            S.appName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: nameColor,
                  fontSize: size * 0.42,
                ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            S.appTagline,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: taglineColor),
          ),
        ],
      ],
    );
  }
}

/// Compact inline logo (glyph + name) for app bars.
class SakanLogoInline extends StatelessWidget {
  const SakanLogoInline({super.key, this.size = 34, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppGradients.primary(c),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          alignment: Alignment.center,
          child: Text(
            'س',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w800,
              fontSize: size * 0.5,
              color: c.primaryForeground,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          S.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: onDark ? Colors.white : c.foreground,
              ),
        ),
      ],
    );
  }
}
