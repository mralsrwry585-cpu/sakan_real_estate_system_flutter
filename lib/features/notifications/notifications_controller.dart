import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notifications_repository.dart';
import '../../models/app_notification.dart';
import '../../providers/app_providers.dart';
import '../auth/auth_controller.dart';

/// Loads the derived notifications feed and tracks read-state in memory
/// (persisted to prefs) so marking-as-read updates instantly without a refetch.
class NotificationsController
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsController(this._repo, this._tenantId)
      : super(const AsyncValue.loading()) {
    load();
  }

  final NotificationsRepository _repo;
  final String _tenantId;

  Future<void> load() async {
    if (_tenantId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.getNotifications(_tenantId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    state = state.whenData(
      (list) => [
        for (final n in list) if (n.id == id) n.copyWith(isRead: true) else n,
      ],
    );
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;
    await _repo.markAllRead(current.map((n) => n.id));
    state = state.whenData(
      (list) => [for (final n in list) n.copyWith(isRead: true)],
    );
  }
}

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController, AsyncValue<List<AppNotification>>>((ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return NotificationsController(
    ref.watch(notificationsRepositoryProvider),
    tenantId,
  );
});

/// Unread badge count for the Home bell.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  return state.valueOrNull?.where((n) => !n.isRead).length ?? 0;
});
