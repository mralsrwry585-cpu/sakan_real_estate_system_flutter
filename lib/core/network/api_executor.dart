import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Runs a Dio-backed call and normalizes every failure into an [ApiException].
///
/// Datasources wrap each request in this so repositories/UI only ever deal with
/// a single, typed error shape.
Future<T> execute<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on ApiException {
    rethrow;
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  } catch (e) {
    throw ApiException(
      kind: ApiErrorKind.unknown,
      message: 'حدث خطأ غير متوقع',
    );
  }
}
