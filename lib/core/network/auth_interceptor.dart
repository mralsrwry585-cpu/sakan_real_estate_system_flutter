import 'package:dio/dio.dart';

/// Attaches the bearer token to outgoing requests and surfaces 401s so the
/// session can be cleared and the user routed back to login.
///
/// The token is read lazily via [tokenProvider] (an in-memory getter backed by
/// the session store), so a fresh login is picked up without rebuilding Dio.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.onUnauthorized,
  });

  /// Returns the current JWT, or null when signed out.
  final String? Function() tokenProvider;

  /// Invoked once when a 401 is observed (clear session + redirect to login).
  final void Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized();
    }
    handler.next(err);
  }
}
