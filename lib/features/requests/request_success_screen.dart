import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../widgets/app_button.dart';

/// Arguments passed to [RequestSuccessScreen] via go_router `extra`.
class RequestSuccessArgs {
  const RequestSuccessArgs({
    required this.isBooking,
    required this.reference,
  });

  /// true → booking request, false → viewing request.
  final bool isBooking;

  /// Human-visible reference: the booking number, or the viewing request id.
  final String reference;
}

/// Full-screen confirmation shown after a viewing/booking request is created.
class RequestSuccessScreen extends StatelessWidget {
  const RequestSuccessScreen({super.key, required this.args});

  final RequestSuccessArgs args;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final body = args.isBooking ? S.bookingSentBody : S.viewingSentBody;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: c.success.tint(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 68,
                  color: c.success,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                S.requestSentTitle,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: c.mutedForeground),
              ),
              if (args.reference.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${S.requestNumber}: ',
                        style: text.bodyMedium
                            ?.copyWith(color: c.mutedForeground),
                      ),
                      Text(
                        args.reference,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              AppButton(
                label: S.viewMyRequests,
                icon: Icons.receipt_long_rounded,
                onPressed: () => context.go(Routes.requests),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: S.browseProperties,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
