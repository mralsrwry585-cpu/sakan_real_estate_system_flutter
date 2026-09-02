import 'package:flutter/widgets.dart';

/// Border-radius scale, mirrored from Lovable (`--radius: 0.75rem`).
/// sm 8 · md 10 · lg 12 · xl 16 · 2xl 20 · full (pill).
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12; // buttons, inputs, chips-as-buttons
  static const double xl = 16; // cards
  static const double xxl = 20; // dialogs / sheets
  static const double full = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}
