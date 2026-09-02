import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/booking_request.dart';
import '../../models/viewing_request.dart';
import '../../providers/app_providers.dart';
import '../auth/auth_controller.dart';

int _epoch(DateTime? d) => d?.millisecondsSinceEpoch ?? 0;

/// The current tenant's viewing requests, newest first.
final myViewingsProvider =
    FutureProvider.autoDispose<List<ViewingRequest>>((ref) async {
  final tenantId = ref.watch(currentTenantIdProvider);
  if (tenantId.isEmpty) return const [];
  final res =
      await ref.watch(requestRepositoryProvider).getViewings(tenantId: tenantId);
  final items = [...res.items]
    ..sort((a, b) => _epoch(b.createdAt).compareTo(_epoch(a.createdAt)));
  return items;
});

/// The current tenant's booking requests, newest first.
final myBookingsProvider =
    FutureProvider.autoDispose<List<BookingRequest>>((ref) async {
  final tenantId = ref.watch(currentTenantIdProvider);
  if (tenantId.isEmpty) return const [];
  final res =
      await ref.watch(requestRepositoryProvider).getBookings(tenantId: tenantId);
  final items = [...res.items]
    ..sort((a, b) => _epoch(b.createdAt).compareTo(_epoch(a.createdAt)));
  return items;
});
