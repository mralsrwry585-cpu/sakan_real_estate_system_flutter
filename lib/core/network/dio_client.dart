import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Builds the single, shared [Dio] instance for the app.
///
/// Centralizes base URL, timeouts, JSON handling, auth, and dev logging so no
/// feature ever constructs its own HTTP client.
class DioClient {
  const DioClient._();

  static Dio create({
    required String? Function() tokenProvider,
    required void Function() onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // We parse non-2xx bodies ourselves in ApiException, but let Dio throw
        // so errors flow through the error interceptor path.
        validateStatus: (status) => status != null && status >= 200 && status < 300,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onUnauthorized: onUnauthorized,
      ),
    );

    if (AppConfig.enableHttpLogging) {
      dio.interceptors.add(_LoggingInterceptor());
    }

    return dio;
  }
}

/// Lightweight request/response logger for development only.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '→ ${options.method} ${options.uri}',
      name: 'SAKAN.http',
    );
    if (options.data != null) {
      developer.log('  body: ${options.data}', name: 'SAKAN.http');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'SAKAN.http',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri} :: ${err.message}',
      name: 'SAKAN.http',
      error: err.response?.data,
    );
    handler.next(err);
  }
}
