import 'package:intl/intl.dart';

import '../localization/app_strings.dart';
import 'enums.dart';

/// Presentation-only formatting helpers (currency, area, dates, times).
///
/// Uses Western digits with thousands grouping (common in Saudi listings) and
/// Arabic month/day names via the `ar` locale (initialized in `main`).
class Fmt {
  const Fmt._();

  static final NumberFormat _grouped = NumberFormat('#,##0', 'en');
  static final NumberFormat _grouped2 = NumberFormat('#,##0.##', 'en');

  /// e.g. 1500000 → "1,500,000".
  static String number(num value) => _grouped.format(value);

  /// Price with currency suffix: "1,500,000 ر.س".
  static String price(num value) => '${_grouped2.format(value)} ${S.currency}';

  /// Price + contract cadence: "5,000 ر.س / شهرياً".
  static String priceWithContract(num value, ContractType contract) {
    final suffix = contract.priceSuffix;
    final base = price(value);
    return suffix.isEmpty ? base : '$base $suffix';
  }

  /// Area: "250 م²".
  static String area(num value) => '${_grouped2.format(value)} ${S.areaUnit}';

  /// Full date: "24 أغسطس 2026".
  static String date(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('d MMMM yyyy', 'ar').format(d.toLocal());
  }

  /// Compact date: "2026/08/24".
  static String dateShort(DateTime? d) {
    if (d == null) return '—';
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$y/$m/$day';
  }

  /// Date + time: "24 أغسطس 2026 · 03:30 م".
  static String dateTime(DateTime? d) {
    if (d == null) return '—';
    return '${date(d)} · ${DateFormat('hh:mm a', 'ar').format(d.toLocal())}';
  }

  /// Normalizes a "HH:mm" or "HH:mm:ss" string to a display "hh:mm a".
  static String time(String raw) {
    if (raw.isEmpty) return '—';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final dt = DateTime(2000, 1, 1, h, m);
    return DateFormat('hh:mm a', 'ar').format(dt);
  }

  /// Relative time for feeds: "الآن"، "منذ ٣ ساعات"، "أمس"، or a date.
  static String relative(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d.toLocal());
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'منذ $m ${_plural(m, 'دقيقة', 'دقيقتين', 'دقائق')}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'منذ $h ${_plural(h, 'ساعة', 'ساعتين', 'ساعات')}';
    }
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) {
      final dd = diff.inDays;
      return 'منذ $dd ${_plural(dd, 'يوم', 'يومين', 'أيام')}';
    }
    return date(d);
  }

  /// Simplified Arabic pluralization for small feed counts.
  static String _plural(int n, String one, String two, String many) {
    if (n == 1) return one;
    if (n == 2) return two;
    if (n >= 3 && n <= 10) return many;
    return one;
  }
}
