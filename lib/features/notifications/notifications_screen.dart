import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_notification.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final hasUnread =
        async.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.notifications),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: controller.markAllRead,
              child: const Text(S.markAllRead),
            ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(error: e, onRetry: controller.load),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: S.emptyNotifications,
              message: S.emptyNotificationsHint,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationTile(
                notification: items[i],
                onTap: () {
                  controller.markRead(items[i].id);
                  context.push(Routes.propertyDetails(items[i].propertyId));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final tone = _toneColor(notification.tone, c);
    final unread = !notification.isRead;

    return Material(
      color: unread ? c.secondary.tint(0.5) : c.surface,
      borderRadius: AppRadius.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            border: Border.all(color: c.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tone.tint(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_toneIcon(notification), color: tone, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: text.titleSmall?.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 4, right: 2),
                            decoration: BoxDecoration(
                              color: c.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(color: c.mutedForeground),
                    ),
                    if ((notification.ownerResponseNote ?? '')
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.ownerResponseNote!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      Fmt.relative(notification.timestamp),
                      style: text.bodySmall?.copyWith(color: c.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _toneIcon(AppNotification n) {
    switch (n.tone) {
      case NotificationTone.approved:
        return Icons.check_circle_rounded;
      case NotificationTone.rejected:
        return Icons.cancel_rounded;
      case NotificationTone.completed:
        return Icons.task_alt_rounded;
      case NotificationTone.neutral:
        return n.kind == NotificationKind.booking
            ? Icons.vpn_key_rounded
            : Icons.event_available_rounded;
    }
  }

  Color _toneColor(NotificationTone tone, SakanColors c) {
    switch (tone) {
      case NotificationTone.approved:
        return c.success;
      case NotificationTone.rejected:
        return c.destructive;
      case NotificationTone.completed:
        return c.info;
      case NotificationTone.neutral:
        return c.mutedForeground;
    }
  }
}
