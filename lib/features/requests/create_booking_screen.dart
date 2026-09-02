import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_request.dart';
import '../../models/property.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/message_banner.dart';
import 'create_request_controller.dart';
import 'request_success_screen.dart';
import 'widgets/request_property_header.dart';
import 'widgets/request_field_tile.dart';

/// Form to submit a booking (rental reservation) request.
class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({
    super.key,
    required this.propertyId,
    this.property,
  });

  final String propertyId;
  final PropertyDetails? property;

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _noteController = TextEditingController();
  DateTime? _startDate;
  int _durationMonths = 12;
  bool _showValidation = false;

  static const _minMonths = 1;
  static const _maxMonths = 60;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _setDuration(int value) {
    setState(() => _durationMonths = value.clamp(_minMonths, _maxMonths));
  }

  Future<void> _submit() async {
    setState(() => _showValidation = true);
    if (_startDate == null) return;

    final tenantId = ref.read(currentTenantIdProvider);
    if (tenantId.isEmpty) {
      context.go(Routes.login);
      return;
    }

    final request = CreateBookingRequest(
      propertyId: widget.propertyId,
      tenantId: tenantId,
      startDate: _startDate!,
      durationMonths: _durationMonths,
      note: _noteController.text,
    );

    final created = await ref
        .read(createRequestControllerProvider.notifier)
        .submitBooking(request);

    if (created != null && mounted) {
      context.pushReplacement(
        Routes.requestSuccess,
        extra: RequestSuccessArgs(
          isBooking: true,
          reference: _reference(created),
        ),
      );
    }
  }

  static String _reference(BookingRequest r) {
    if (r.bookingNumber.trim().isNotEmpty) return r.bookingNumber.trim();
    final id = r.id.replaceAll('-', '');
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(createRequestControllerProvider);
    final isLoading = submitState.isLoading;
    final error = submitState.hasError ? submitState.error : null;

    return Scaffold(
      appBar: AppBar(title: const Text(S.bookingRequest)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.property != null)
              RequestPropertyHeader(property: widget.property!),
            const SizedBox(height: 20),
            if (error != null) ...[
              MessageBanner(
                message: _composeError(error),
                tone: BannerTone.error,
              ),
              const SizedBox(height: 16),
            ],
            RequestFieldTile(
              icon: Icons.event_outlined,
              label: S.startDate,
              value: _startDate == null ? S.pickDate : Fmt.date(_startDate),
              filled: _startDate != null,
              onTap: _pickDate,
              error:
                  _showValidation && _startDate == null ? S.required : null,
            ),
            const SizedBox(height: 18),
            _DurationStepper(
              months: _durationMonths,
              min: _minMonths,
              max: _maxMonths,
              onChanged: _setDuration,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: S.note,
              hint: S.noteHint,
              controller: _noteController,
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: S.submitBooking,
              icon: Icons.send_rounded,
              loading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _composeError(Object error) {
    if (error is ApiException) {
      if (error.fieldErrors.isNotEmpty) {
        return error.fieldErrors.values.join('\n');
      }
      return error.message;
    }
    return S.somethingWentWrong;
  }
}

class _DurationStepper extends StatelessWidget {
  const _DurationStepper({
    required this.months,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int months;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 2),
          child: Text(
            S.durationMonths,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _presets)
              AppChoiceChip(
                label: _presetLabel(preset),
                selected: months == preset,
                onTap: () => onChanged(preset),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                enabled: months > min,
                onTap: () => onChanged(months - 1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$months',
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _monthsLabel(months),
                      style: text.bodySmall
                          ?.copyWith(color: c.mutedForeground),
                    ),
                  ],
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                enabled: months < max,
                onTap: () => onChanged(months + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _presets = [3, 6, 12, 24];

  static String _presetLabel(int n) {
    switch (n) {
      case 12:
        return 'سنة';
      case 24:
        return 'سنتان';
      default:
        return '$n ${_monthsLabel(n)}';
    }
  }

  static String _monthsLabel(int n) {
    if (n == 1) return 'شهر';
    if (n == 2) return 'شهران';
    if (n >= 3 && n <= 10) return 'أشهر';
    return 'شهراً';
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: c.secondary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: c.primary, size: 24),
          ),
        ),
      ),
    );
  }
}
