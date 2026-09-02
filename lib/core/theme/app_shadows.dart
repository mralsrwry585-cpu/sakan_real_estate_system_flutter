import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SAKAN elevation tokens, mirrored from the Lovable `--shadow-*` tokens.
class AppShadows {
  const AppShadows._();

  /// `shadow-card` — subtle card elevation.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      spreadRadius: -12,
      offset: Offset(0, 8),
    ),
  ];

  /// `shadow-elegant` — primary-tinted glow for CTAs, dialogs, hero surfaces.
  static List<BoxShadow> elegant(SakanColors c) => [
        BoxShadow(
          color: c.primary.tint(0.30),
          blurRadius: 40,
          spreadRadius: -20,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: c.primary.tint(0.20),
          blurRadius: 16,
          spreadRadius: -12,
          offset: const Offset(0, 8),
        ),
      ];
}
