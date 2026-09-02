import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Central runtime configuration for the SAKAN tenant app.
class AppConfig {
  const AppConfig._();

  /// Explicit compile-time override. Wins over the platform default when set:
  ///   --dart-define=API_BASE_URL=http://192.168.x.x:5226
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the SAKAN.API backend, resolved per platform.
  ///
  /// The Android emulator cannot reach the host's `localhost`; it maps the
  /// host loopback to the special alias `10.0.2.2`. Web and desktop builds
  /// (including the Chrome preview) talk to `localhost` directly. A
  /// `--dart-define=API_BASE_URL=...` override always takes precedence.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5226';
    }
    return 'http://localhost:5226';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Default page size used by paginated lists.
  static const int pageSize = 10;

  /// Enable verbose Dio request/response logging (development only).
  static const bool enableHttpLogging = true;
}
