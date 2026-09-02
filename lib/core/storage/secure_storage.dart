import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over [FlutterSecureStorage] with sensible Android options.
///
/// Keeping this behind an interface makes the session layer testable and keeps
/// key names in one place.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  // Keys
  static const _kSession = 'sakan.session';

  Future<String?> readSession() => _storage.read(key: _kSession);

  Future<void> writeSession(String value) =>
      _storage.write(key: _kSession, value: value);

  Future<void> deleteSession() => _storage.delete(key: _kSession);
}
