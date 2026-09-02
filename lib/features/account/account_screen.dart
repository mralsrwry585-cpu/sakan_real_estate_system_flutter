import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../auth/auth_controller.dart';
import '../shell/main_shell.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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
            child: Text(
              S.logout,
              style: TextStyle(color: ctx.colors.destructive),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        leading: const AppDrawerButton(),
        title: const Text(S.navAccount),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavSpace),
        children: [
          _ProfileHeader(
            name: user?.fullName ?? '',
            email: user?.email ?? '',
            initials: user?.initials ?? '؟',
          ),
          const SizedBox(height: 24),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                label: S.myRequests,
                onTap: () => context.go(Routes.requests),
              ),
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                label: S.favorites,
                onTap: () => context.go(Routes.favorites),
              ),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                label: S.notifications,
                onTap: () => context.push(Routes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.settings_outlined,
                label: S.settings,
                onTap: () => context.push(Routes.settings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.logout_rounded,
                label: S.logout,
                destructive: true,
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initials,
  });

  final String name;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: AppRadius.brXl,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.tint(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.tint(0.5), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: text.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? S.appName : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(color: Colors.white.tint(0.85)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.tint(0.2),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Text(
                    S.tenant,
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
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = destructive ? c.destructive : c.foreground;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: destructive ? c.destructive : c.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            if (!destructive)
              Icon(Icons.chevron_left_rounded, color: c.mutedForeground),
          ],
        ),
      ),
    );
  }
}
