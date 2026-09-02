import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/formatters.dart';
import '../../models/property.dart';
import '../../models/viewing_request.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/message_banner.dart';
import 'create_request_controller.dart';
import 'request_success_screen.dart';
import 'widgets/request_property_header.dart';
import 'widgets/request_field_tile.dart';

/// Form to submit a viewing (property tour) request.
class CreateViewingScreen extends ConsumerStatefulWidget {
  const CreateViewingScreen({
    super.key,
    required this.propertyId,
    this.property,
  });

  final String propertyId;
  final PropertyDetails? property;

  @override
  ConsumerState<CreateViewingScreen> createState() =>
      _CreateViewingScreenState();
}

class _CreateViewingScreenState extends ConsumerState<CreateViewingScreen> {
  final _noteController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _showValidation = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    setState(() => _showValidation = true);
    if (_date == null || _time == null) return;

    final tenantId = ref.read(currentTenantIdProvider);
    if (tenantId.isEmpty) {
      context.go(Routes.login);
      return;
    }

    final request = CreateViewingRequest(
      propertyId: widget.propertyId,
      tenantId: tenantId,
      requestedDate: _date!,
      requestedTime: _hhmm(_time!),
      note: _noteController.text,
    );

    final created = await ref
        .read(createRequestControllerProvider.notifier)
        .submitViewing(request);

    if (created != null && mounted) {
      context.pushReplacement(
        Routes.requestSuccess,
        extra: RequestSuccessArgs(
          isBooking: false,
          reference: _shortRef(created),
        ),
      );
    }
  }

  static String _shortRef(ViewingRequest r) {
    final id = r.id.replaceAll('-', '');
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(createRequestControllerProvider);
    final isLoading = submitState.isLoading;
    final error = submitState.hasError ? submitState.error : null;

    return Scaffold(
      appBar: AppBar(title: const Text(S.viewingRequest)),
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
              label: S.requestedDate,
              value: _date == null ? S.pickDate : Fmt.date(_date),
              filled: _date != null,
              onTap: _pickDate,
              error: _showValidation && _date == null ? S.required : null,
            ),
            const SizedBox(height: 14),
            RequestFieldTile(
              icon: Icons.schedule_outlined,
              label: S.requestedTime,
              value: _time == null ? S.pickTime : _hhmm(_time!),
              filled: _time != null,
              onTap: _pickTime,
              error: _showValidation && _time == null ? S.required : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: S.note,
              hint: S.noteHint,
              controller: _noteController,
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: S.submitViewing,
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
