import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SAKAN gradients, mirrored from the Lovable `--gradient-*` tokens.
class AppGradients {
  const AppGradients._();

  /// `gradient-primary` — 135°, primary → primary-glow. Adapts to theme.
  static LinearGradient primary(SakanColors c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c.primary, c.primaryGlow],
      );

  /// `gradient-gold` — 135°, #EEBB58 → #DC932E (constant across themes).
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEBB58), Color(0xFFDC932E)],
  );

  /// `gradient-hero` — deep teal, used on splash/home/profile/drawer headers.
  /// Kept constant (a dark teal) in both themes for a premium header look.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.6, 1.0],
    colors: [Color(0xFF034747), Color(0xFF003033), Color(0xFF001F25)],
  );
}
