import '../core/utils/enums.dart';

/// The authenticated tenant's identity, persisted across sessions.
class AuthUser {
  const AuthUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String userId;
  final String fullName;
  final String email;
  final UserRole role;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: (json['userId'] ?? json['id'] ?? '').toString(),
        fullName: (json['fullName'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: UserRole.fromValue((json['role'] as num?)?.toInt()),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'role': role.value,
      };

  /// First name for greetings ("أهلاً محمد").
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  /// Up to two initials for avatars.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) {
      return _firstGlyph(parts.first);
    }
    return _firstGlyph(parts.first) + _firstGlyph(parts[1]);
  }

  static String _firstGlyph(String s) => s.isEmpty ? '' : s.substring(0, 1);
}

/// Full auth response: bearer token + user identity.
class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: (json['token'] ?? '').toString(),
        user: AuthUser.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
      };

  /// Restores a persisted session from the wrapped `{token, user}` shape.
  factory AuthResult.fromStored(Map<String, dynamic> json) => AuthResult(
        token: (json['token'] ?? '').toString(),
        user: AuthUser.fromJson(
            (json['user'] as Map).cast<String, dynamic>()),
      );
}

/// Login request body — the backend authenticates by **email**.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };
}

/// Registration request body. Tenants always register with role = Tenant(0).
class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.mobile,
    required this.nationalId,
    required this.email,
    required this.password,
    this.role = UserRole.tenant,
  });

  final String fullName;
  final String mobile;
  final String nationalId;
  final String email;
  final String password;
  final UserRole role;

  Map<String, dynamic> toJson() => {
        'fullName': fullName.trim(),
        'mobile': mobile.trim(),
        'nationalId': nationalId.trim(),
        'email': email.trim(),
        'password': password,
        'role': role.value,
      };
}
