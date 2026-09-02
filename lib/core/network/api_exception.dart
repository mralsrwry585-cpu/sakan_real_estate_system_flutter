import 'package:dio/dio.dart';

import '../localization/app_strings.dart';

/// Classifies failures so the UI can react (retry vs. re-auth vs. field errors).
enum ApiErrorKind {
  network, // no connection / timeout
  timeout,
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  validation, // 400/422 with field errors
  conflict, // 409 (duplicate email/mobile/nationalId, etc.)
  server, // 5xx
  unknown,
  cancelled,
}

/// A normalized, presentation-ready error.
///
/// Parses BOTH backend error envelopes:
///  - PascalCase: `{ StatusCode, Message, Errors: [{ Field, Error }] }`
///  - ProblemDetails: `{ title, detail, status, errors: { field: [..] } }`
class ApiException implements Exception {
  ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  /// Field-name → first error message, for inline form validation display.
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;

  /// Returns the field error for [field] (case-insensitive), if any.
  String? fieldError(String field) {
    final lower = field.toLowerCase();
    for (final entry in fieldErrors.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  @override
  String toString() => 'ApiException($kind, $statusCode): $message';

  /// Builds an [ApiException] from any Dio failure.
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(kind: ApiErrorKind.timeout, message: S.noInternet);
      case DioExceptionType.connectionError:
        return ApiException(kind: ApiErrorKind.network, message: S.noInternet);
      case DioExceptionType.cancel:
        return ApiException(
            kind: ApiErrorKind.cancelled, message: S.somethingWentWrong);
      case DioExceptionType.badCertificate:
        return ApiException(
            kind: ApiErrorKind.network, message: S.noInternet);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final response = e.response;
    if (response == null) {
      return ApiException(kind: ApiErrorKind.network, message: S.noInternet);
    }
    return ApiException.fromResponse(response.statusCode, response.data);
  }

  /// Builds an [ApiException] from a status code + parsed body.
  factory ApiException.fromResponse(int? status, dynamic data) {
    final fieldErrors = _parseFieldErrors(data);
    final message = _parseMessage(data) ?? _defaultMessageFor(status);
    final kind = _kindFor(status, fieldErrors.isNotEmpty);
    return ApiException(
      kind: kind,
      message: message,
      statusCode: status,
      fieldErrors: fieldErrors,
    );
  }

  static ApiErrorKind _kindFor(int? status, bool hasFieldErrors) {
    if (status == null) return ApiErrorKind.unknown;
    if (status == 401) return ApiErrorKind.unauthorized;
    if (status == 403) return ApiErrorKind.forbidden;
    if (status == 404) return ApiErrorKind.notFound;
    if (status == 409) return ApiErrorKind.conflict;
    if (status == 400 || status == 422) return ApiErrorKind.validation;
    if (hasFieldErrors) return ApiErrorKind.validation;
    if (status >= 500) return ApiErrorKind.server;
    return ApiErrorKind.unknown;
  }

  static String _defaultMessageFor(int? status) {
    if (status == null) return S.somethingWentWrong;
    if (status == 401) return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
    if (status == 403) return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
    if (status == 404) return 'العنصر المطلوب غير موجود';
    if (status == 409) return 'البيانات المُدخلة مستخدمة مسبقاً';
    if (status >= 500) return 'حدث خطأ في الخادم، حاول لاحقاً';
    return S.somethingWentWrong;
  }

  static String? _parseMessage(dynamic data) {
    if (data is Map) {
      // PascalCase envelope
      final msg = data['Message'] ?? data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
      // ProblemDetails
      final detail = data['detail'] ?? data['Detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      final title = data['title'] ?? data['Title'];
      if (title is String && title.trim().isNotEmpty) return title;
    }
    if (data is String && data.trim().isNotEmpty && data.length < 300) {
      return data;
    }
    return null;
  }

  static Map<String, String> _parseFieldErrors(dynamic data) {
    final result = <String, String>{};
    if (data is! Map) return result;

    // PascalCase: Errors: [{ Field, Error }]
    final errorsList = data['Errors'] ?? data['errors'];
    if (errorsList is List) {
      for (final item in errorsList) {
        if (item is Map) {
          final field = (item['Field'] ?? item['field'])?.toString();
          final error = (item['Error'] ?? item['error'] ?? item['message'])
              ?.toString();
          if (field != null && error != null) result[field] = error;
        }
      }
    }

    // ProblemDetails: errors: { field: [messages] }
    if (errorsList is Map) {
      errorsList.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          result[key.toString()] = value.first.toString();
        } else if (value is String) {
          result[key.toString()] = value;
        }
      });
    }

    return result;
  }
}
