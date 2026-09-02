import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/status_ui.dart';
import '../../../models/booking_request.dart';
import '../../../models/viewing_request.dart';
import '../../../widgets/status_pill.dart';

/// A card summarizing a single viewing or booking request. Tapping opens the
/// related property. Use the [RequestCard.viewing] / [RequestCard.booking]
/// constructors.
class RequestCard extends StatelessWidget {
  const RequestCard._({
    required this.icon,
    required this.typeLabel,
    required this.propertyId,
    required this.propertyTitle,
    required this.visual,
    required this.rows,
    required this.timestamp,
    this.ownerResponseNote,
  });

  factory RequestCard.viewing(ViewingRequest r, {required SakanColors c}) {
    return RequestCard._(
      icon: Icons.event_available_outlined,
      typeLabel: S.viewingRequest,
      propertyId: r.propertyId,
      propertyTitle: r.propertyTitle,
      visual: StatusUi.viewing(r.status, c),
      timestamp: r.createdAt,
      ownerResponseNote: r.ownerResponseNote,
      rows: [
        _InfoRow(Icons.calendar_today_outlined, Fmt.date(r.requestedDate)),
        _InfoRow(Icons.schedule_outlined, Fmt.time(r.requestedTime)),
        if ((r.note ?? '').trim().isNotEmpty)
          _InfoRow(Icons.notes_outlined, r.note!.trim()),
      ],
    );
  }

  factory RequestCard.booking(BookingRequest r, {required SakanColors c}) {
    return RequestCard._(
      icon: Icons.vpn_key_outlined,
      typeLabel: S.bookingRequest,
      propertyId: r.propertyId,
      propertyTitle: r.propertyTitle,
      visual: StatusUi.booking(r.status, c),
      timestamp: r.createdAt,
      ownerResponseNote: r.ownerResponseNote,
      rows: [
        if (r.bookingNumber.trim().isNotEmpty)
          _InfoRow(Icons.tag_rounded, r.bookingNumber.trim()),
        _InfoRow(Icons.calendar_today_outlined, Fmt.date(r.startDate)),
        _InfoRow(Icons.timelapse_outlined, _duration(r.durationMonths)),
        if ((r.note ?? '').trim().isNotEmpty)
          _InfoRow(Icons.notes_outlined, r.note!.trim()),
      ],
    );
  }

  final IconData icon;
  final String typeLabel;
  final String propertyId;
  final String propertyTitle;
  final StatusVisual visual;
  final List<Widget> rows;
  final DateTime? timestamp;
  final String? ownerResponseNote;

  static String _duration(int months) {
    final label = months == 1
        ? 'شهر'
        : months == 2
            ? 'شهران'
            : (months >= 3 && months <= 10)
                ? 'أشهر'
                : 'شهراً';
    return '$months $label';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Material(
      color: c.surface,
      borderRadius: AppRadius.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.propertyDetails(propertyId)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            border: Border.all(color: c.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: c.primary),
                  const SizedBox(width: 6),
                  Text(
                    typeLabel,
                    style: text.labelMedium?.copyWith(color: c.mutedForeground),
                  ),
                  const Spacer(),
                  StatusPill(visual: visual, compact: true),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                propertyTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              for (final row in rows) ...[
                row,
                const SizedBox(height: 6),
              ],
              if ((ownerResponseNote ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.secondary,
                    borderRadius: AppRadius.brMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.ownerResponse,
                        style: text.labelSmall
                            ?.copyWith(color: c.secondaryForeground),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ownerResponseNote!.trim(),
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
              if (timestamp != null) ...[
                const SizedBox(height: 8),
                Text(
                  Fmt.relative(timestamp),
                  style: text.bodySmall?.copyWith(color: c.mutedForeground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.value);

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.mutedForeground),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
