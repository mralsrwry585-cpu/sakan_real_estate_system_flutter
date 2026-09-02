import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-secure app preferences: theme mode and locally-tracked read
/// notification ids (since notifications are derived client-side).
class PreferencesStore {
  PreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'sakan.themeMode';
  static const _kReadNotifications = 'sakan.readNotifications';

  // ── Theme ──────────────────────────────────────────────
  ThemeMode getThemeMode() {
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_kThemeMode, value);
  }

  // ── Read notifications ─────────────────────────────────
  Set<String> getReadNotificationIds() =>
      (_prefs.getStringList(_kReadNotifications) ?? const []).toSet();

  Future<void> markRead(String id) async {
    final set = getReadNotificationIds()..add(id);
    await _prefs.setStringList(_kReadNotifications, set.toList());
  }

  Future<void> markAllRead(Iterable<String> ids) async {
    final set = getReadNotificationIds()..addAll(ids);
    await _prefs.setStringList(_kReadNotifications, set.toList());
  }
}
