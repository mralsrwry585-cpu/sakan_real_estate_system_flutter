
class AppConfig {
  const AppConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // رابط ملف الـ PHP على موقعك مباشرة
    return 'https://desraj.in/index.php';
    // ملاحظة: لو وضعت الملف داخل مجلد فرعي مثل sakan اجعله:
    // return 'https://desraj.in/sakan/index.php';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int pageSize = 10;
  static const bool enableHttpLogging = true;
}
