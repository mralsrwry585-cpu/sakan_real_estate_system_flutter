import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_executor.dart';
import '../../models/auth_models.dart';

/// Talks to the auth endpoints. Login authenticates by **email**.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResult> login(LoginRequest request) => execute(() async {
        final res = await _dio.post(ApiEndpoints.login, data: request.toJson());
        return AuthResult.fromJson((res.data as Map).cast<String, dynamic>());
      });

  Future<AuthResult> register(RegisterRequest request) => execute(() async {
        final res =
            await _dio.post(ApiEndpoints.register, data: request.toJson());
        return AuthResult.fromJson((res.data as Map).cast<String, dynamic>());
      });
}
