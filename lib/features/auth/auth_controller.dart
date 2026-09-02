import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../models/auth_models.dart';
import '../../providers/app_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Global authentication state consumed by the router for redirects.
class AuthState {
  const AuthState({required this.status, this.user});

  final AuthStatus status;
  final AuthUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null;

  AuthState copyWith({AuthStatus? status, AuthUser? user}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
      );
}

/// Owns login/register/logout and the derived [AuthState].
///
/// Auth *errors* are thrown (as `ApiException`) to the calling screen so it can
/// render inline messages; this controller only tracks the resolved session.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo)
      : super(
          _repo.isAuthenticated
              ? AuthState(status: AuthStatus.authenticated, user: _repo.currentUser)
              : const AuthState(status: AuthStatus.unauthenticated),
        );

  final AuthRepository _repo;

  AuthUser? get user => state.user;

  Future<void> login({required String email, required String password}) async {
    final result = await _repo.login(email: email, password: password);
    state = AuthState(status: AuthStatus.authenticated, user: result.user);
  }

  Future<void> register(RegisterRequest request) async {
    final result = await _repo.register(request);
    state = AuthState(status: AuthStatus.authenticated, user: result.user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    // Rebuild (→ signed-out) whenever the Dio interceptor reports a 401.
    ref.watch(sessionRevisionProvider);
    return AuthController(ref.watch(authRepositoryProvider));
  },
);

/// Convenience: the current tenant's id (empty when signed out).
final currentTenantIdProvider = Provider<String>(
  (ref) => ref.watch(authControllerProvider).user?.userId ?? '',
);
