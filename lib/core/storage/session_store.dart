import 'dart:convert';

import '../../models/auth_models.dart';
import 'secure_storage.dart';

/// Owns the authenticated session in memory and persists it securely.
///
/// The in-memory [token] getter is what the Dio [AuthInterceptor] reads on
/// every request, so login/logout take effect immediately without rebuilding
/// the HTTP client. [load] restores a persisted session on app start.
class SessionStore {
  SessionStore(this._secure);

  final SecureStorage _secure;

  AuthResult? _current;

  AuthResult? get current => _current;
  AuthUser? get user => _current?.user;
  String? get token => _current?.token;
  bool get isAuthenticated => (_current?.token.isNotEmpty ?? false);

  /// Restores a previously saved session into memory. Safe to call once at
  /// startup; tolerates corrupt/missing data by clearing it.
  Future<AuthResult?> load() async {
    try {
      final raw = await _secure.readSession();
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _current = AuthResult.fromStored(map);
      if (_current!.token.isEmpty) {
        await clear();
        return null;
      }
      return _current;
    } catch (_) {
      await clear();
      return null;
    }
  }

  /// Persists and caches a fresh session after login/register.
  Future<void> save(AuthResult result) async {
    _current = result;
    await _secure.writeSession(jsonEncode(result.toJson()));
  }

  /// Clears the session from memory and disk (logout / 401).
  Future<void> clear() async {
    _current = null;
    await _secure.deleteSession();
  }
}
