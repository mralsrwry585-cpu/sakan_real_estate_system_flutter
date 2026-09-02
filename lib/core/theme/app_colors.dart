import 'package:flutter/material.dart';

/// Full SAKAN design-system palette, mirrored 1:1 from the Lovable theme
/// (`sakan-lovable/src/styles.css`, OKLCH tokens resolved to sRGB).
///
/// Two instances are provided ([light] and [dark]). Resolve the active one
/// for a [BuildContext] via `context.colors` (see [SakanColorsX]).
@immutable
class SakanColors {
  const SakanColors({
    required this.brightness,
    required this.background,
    required this.foreground,
    required this.surface,
    required this.surface2,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.primaryGlow,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.gold,
    required this.goldForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.info,
    required this.infoForeground,
    required this.border,
    required this.input,
    required this.ring,
  });

  final Brightness brightness;
  final Color background;
  final Color foreground;
  final Color surface;
  final Color surface2;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryForeground;
  final Color primaryGlow;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color gold;
  final Color goldForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color info;
  final Color infoForeground;
  final Color border;
  final Color input;
  final Color ring;

  static const SakanColors light = SakanColors(
    brightness: Brightness.light,
    background: Color(0xFFFDFAF4),
    foreground: Color(0xFF0A191A),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF8F5EE),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0A191A),
    primary: Color(0xFF034747),
    primaryForeground: Color(0xFFFDFAF4),
    primaryGlow: Color(0xFF00847E),
    secondary: Color(0xFFE4F2F1),
    secondaryForeground: Color(0xFF113436),
    muted: Color(0xFFF2F0EA),
    mutedForeground: Color(0xFF566768),
    accent: Color(0xFFF1E3C7),
    accentForeground: Color(0xFF113436),
    gold: Color(0xFFE1AF4A),
    goldForeground: Color(0xFF301D0D),
    destructive: Color(0xFFDE3B3D),
    destructiveForeground: Color(0xFFFAFAFA),
    success: Color(0xFF269E5F),
    successForeground: Color(0xFFFAFAFA),
    warning: Color(0xFFEFA831),
    warningForeground: Color(0xFF301D0D),
    info: Color(0xFF338FC7),
    infoForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE0DED7),
    input: Color(0xFFE7E4DD),
    ring: Color(0xFF00847E),
  );

  static const SakanColors dark = SakanColors(
    brightness: Brightness.dark,
    background: Color(0xFF041012),
    foreground: Color(0xFFF5F1EA),
    surface: Color(0xFF091B1F),
    surface2: Color(0xFF081619),
    card: Color(0xFF091B1F),
    cardForeground: Color(0xFFF5F1EA),
    primary: Color(0xFF1DBCB5),
    primaryForeground: Color(0xFF041012),
    primaryGlow: Color(0xFF00DAD2),
    secondary: Color(0xFF162D31),
    secondaryForeground: Color(0xFFF5F1EA),
    muted: Color(0xFF162427),
    mutedForeground: Color(0xFF97A9A9),
    accent: Color(0xFF372C15),
    accentForeground: Color(0xFFF5F1EA),
    gold: Color(0xFFE1AF4A),
    goldForeground: Color(0xFF231103),
    destructive: Color(0xFFF14D4C),
    destructiveForeground: Color(0xFFFAFAFA),
    success: Color(0xFF3FB171),
    successForeground: Color(0xFF020E0E),
    warning: Color(0xFFF5AE39),
    warningForeground: Color(0xFF231103),
    info: Color(0xFF48A1DB),
    infoForeground: Color(0xFF020E0E),
    border: Color(0xFF223133),
    input: Color(0xFF223133),
    ring: Color(0xFF1DBCB5),
  );
}

/// Convenience access to the active [SakanColors] for a [BuildContext].
extension SakanColorsX on BuildContext {
  SakanColors get colors =>
      Theme.of(this).brightness == Brightness.dark
          ? SakanColors.dark
          : SakanColors.light;
}

/// Small helpers around [Color] to keep tint math readable and avoid the
/// deprecated `withOpacity`.
extension ColorTintX on Color {
  Color tint(double alpha) => withValues(alpha: alpha);
}
