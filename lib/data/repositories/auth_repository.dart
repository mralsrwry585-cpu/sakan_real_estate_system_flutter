import '../../core/storage/session_store.dart';
import '../../models/auth_models.dart';
import '../datasources/auth_remote_datasource.dart';

/// Coordinates authentication with session persistence.
class AuthRepository {
  AuthRepository(this._remote, this._session);

  final AuthRemoteDataSource _remote;
  final SessionStore _session;

  AuthUser? get currentUser => _session.user;
  bool get isAuthenticated => _session.isAuthenticated;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(
      LoginRequest(email: email, password: password),
    );
    await _session.save(result);
    return result;
  }

  Future<AuthResult> register(RegisterRequest request) async {
    final result = await _remote.register(request);
    await _session.save(result);
    return result;
  }

  Future<void> logout() => _session.clear();
}
