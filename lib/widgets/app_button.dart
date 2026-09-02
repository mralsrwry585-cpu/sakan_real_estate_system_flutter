import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';

enum AppButtonVariant { primary, gold, secondary, outline, text, destructive }

/// The app's single button primitive, covering every Lovable button style.
///
/// - [primary]/[gold] paint the brand gradients with an elegant glow.
/// - [secondary] is a soft tinted fill; [outline] is bordered; [text] is bare.
/// - Shows a spinner and blocks taps while [loading].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double height;

  bool get _isGradient =>
      variant == AppButtonVariant.primary || variant == AppButtonVariant.gold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !loading;

    final (Color fg, Color? fill, Gradient? gradient, Border? border) =
        switch (variant) {
      AppButtonVariant.primary => (
          c.primaryForeground,
          null,
          AppGradients.primary(c),
          null,
        ),
      AppButtonVariant.gold => (c.goldForeground, null, AppGradients.gold, null),
      AppButtonVariant.secondary => (c.secondaryForeground, c.secondary, null, null),
      AppButtonVariant.destructive => (c.destructiveForeground, c.destructive, null, null),
      AppButtonVariant.outline => (
          c.foreground,
          Colors.transparent,
          null,
          Border.all(color: c.border, width: 1.5),
        ),
      AppButtonVariant.text => (c.primary, Colors.transparent, null, null),
    };

    final content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: fg, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          gradient: enabled ? gradient : null,
          borderRadius: AppRadius.brLg,
          border: border,
          boxShadow: (_isGradient && enabled) ? AppShadows.elegant(c) : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.brLg,
          child: InkWell(
            borderRadius: AppRadius.brLg,
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: height,
              width: expand ? double.infinity : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: expand ? 16 : 22),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
