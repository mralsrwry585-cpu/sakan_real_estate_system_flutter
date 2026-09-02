import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../auth/auth_controller.dart';
import '../favorites/favorites_controller.dart';
import '../notifications/notifications_controller.dart';
import '../requests/requests_providers.dart';

/// The app-wide side menu (RTL → opens from the right), modelled on Lovable's
/// `ScreenDrawer`: a hero-gradient identity header with a live stats grid, the
/// primary destinations with badges, and a sign-out action.
///
/// All figures come from real providers — favorites/viewings/bookings counts —
/// never placeholders.
class SakanDrawer extends ConsumerWidget {
  const SakanDrawer({super.key});

  void _go(BuildContext context, String route) {
    Scaffold.of(context).closeDrawer();
    context.go(route);
  }

  void _push(BuildContext context, String route) {
    Scaffold.of(context).closeDrawer();
    context.push(route);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.logout),
        content: const Text(S.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.logout, style: TextStyle(color: ctx.colors.destructive)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final width = MediaQuery.of(context).size.width;
    final user = ref.watch(authControllerProvider).user;
    final favCount = ref.watch(favoritesProvider).length;
    final unread = ref.watch(unreadNotificationsCountProvider);
    final viewings = ref.watch(myViewingsProvider);
    final bookings = ref.watch(myBookingsProvider);

    String count(AsyncValue<List> v) =>
        v.maybeWhen(data: (l) => '${l.length}', orElse: () => '—');

    return Drawer(
      width: (width * 0.82).clamp(280.0, 360.0),
      backgroundColor: c.surface,
      child: Column(
        children: [
          _Header(
            name: user?.fullName ?? S.appName,
            email: user?.email ?? '',
            initials: user?.initials ?? '؟',
            favorites: '$favCount',
            viewings: count(viewings),
            bookings: count(bookings),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _Item(
                  icon: Icons.home_rounded,
                  label: S.navHome,
                  onTap: () => _go(context, Routes.home),
                ),
                _Item(
                  icon: Icons.search_rounded,
                  label: S.navSearch,
                  onTap: () => _go(context, Routes.search),
                ),
                _Item(
                  icon: Icons.favorite_rounded,
                  label: S.favorites,
                  badge: favCount > 0 ? '$favCount' : null,
                  onTap: () => _go(context, Routes.favorites),
                ),
                _Item(
                  icon: Icons.receipt_long_rounded,
                  label: S.myRequests,
                  onTap: () => _go(context, Routes.requests),
                ),
                _Item(
                  icon: Icons.person_rounded,
                  label: S.navAccount,
                  onTap: () => _go(context, Routes.account),
                ),
                const _SectionDivider(),
                _Item(
                  icon: Icons.notifications_rounded,
                  label: S.notifications,
                  badge: unread > 0 ? '$unread' : null,
                  badgeTone: _BadgeTone.destructive,
                  onTap: () => _push(context, Routes.notifications),
                ),
                _Item(
                  icon: Icons.settings_rounded,
                  label: S.settings,
                  onTap: () => _push(context, Routes.settings),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _Item(
            icon: Icons.logout_rounded,
            label: S.logout,
            destructive: true,
            onTap: () => _logout(context, ref),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                '${S.appName} · v1.0.0',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.mutedForeground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.initials,
    required this.favorites,
    required this.viewings,
    required this.bookings,
  });

  final String name;
  final String email;
  final String initials;
  final String favorites;
  final String viewings;
  final String bookings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: AppGradients.gold,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: text.titleLarge?.copyWith(
                    color: const Color(0xFF301D0D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall
                            ?.copyWith(color: Colors.white.tint(0.8)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.tint(0.18),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Text(
                        'مستأجر مميّز',
                        style: text.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _Stat(value: favorites, label: S.favorites)),
              const SizedBox(width: 10),
              Expanded(child: _Stat(value: viewings, label: S.tabViewings)),
              const SizedBox(width: 10),
              Expanded(child: _Stat(value: bookings, label: S.tabBookings)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.tint(0.12),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: text.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: text.labelSmall?.copyWith(color: Colors.white.tint(0.75)),
          ),
        ],
      ),
    );
  }
}

enum _BadgeTone { primary, destructive }

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeTone = _BadgeTone.primary,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final _BadgeTone badgeTone;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = destructive ? c.destructive : c.primary;
    final labelColor = destructive ? c.destructive : c.foreground;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tint.tint(0.10),
                borderRadius: AppRadius.brMd,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeTone == _BadgeTone.destructive
                      ? c.destructive
                      : c.primary,
                  borderRadius: AppRadius.brFull,
                ),
                child: Text(
                  badge!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            else if (!destructive)
              Icon(Icons.chevron_left_rounded, color: c.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Divider(height: 1, color: context.colors.border),
      );
}
