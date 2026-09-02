import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(S.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(S.appearance),
          _Card(
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  label: S.themeSystem,
                  selected: mode == ThemeMode.system,
                  onTap: () => controller.set(ThemeMode.system),
                ),
                _divider(context),
                _ThemeOption(
                  icon: Icons.light_mode_outlined,
                  label: S.themeLight,
                  selected: mode == ThemeMode.light,
                  onTap: () => controller.set(ThemeMode.light),
                ),
                _divider(context),
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  label: S.themeDark,
                  selected: mode == ThemeMode.dark,
                  onTap: () => controller.set(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(S.language),
          _Card(
            child: _InfoTile(
              icon: Icons.language_rounded,
              label: S.language,
              value: S.arabic,
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(S.about),
          _Card(
            child: _InfoTile(
              icon: Icons.info_outline_rounded,
              label: S.version,
              value: _appVersion,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, color: context.colors.border);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4, top: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: context.colors.mutedForeground),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: c.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: c.primary)
            else
              Icon(Icons.circle_outlined, color: c.border),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: c.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: c.mutedForeground),
          ),
        ],
      ),
    );
  }
}
