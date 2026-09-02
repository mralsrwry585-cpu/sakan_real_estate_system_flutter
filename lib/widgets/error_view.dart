import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import 'app_button.dart';

/// Full-screen error view with a retry action. Understands [ApiException] to
/// pick an appropriate icon (offline vs. generic).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.error, this.message, this.onRetry});

  final Object? error;
  final String? message;
  final VoidCallback? onRetry;

  bool get _isNetwork {
    final e = error;
    return e is ApiException &&
        (e.kind == ApiErrorKind.network || e.kind == ApiErrorKind.timeout);
  }

  String get _message {
    if (message != null) return message!;
    final e = error;
    if (e is ApiException) return e.message;
    return S.somethingWentWrong;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: c.destructive.tint(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 44,
                color: c.destructive,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isNetwork ? 'لا يوجد اتصال' : S.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: c.mutedForeground),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: S.retry,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact inline error (for sections within a scroll view).
class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: c.destructive, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: c.mutedForeground),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(S.retry),
            ),
          ],
        ],
      ),
    );
  }
}
