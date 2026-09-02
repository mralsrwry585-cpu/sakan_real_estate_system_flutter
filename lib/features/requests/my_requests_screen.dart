import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_request.dart';
import '../../models/viewing_request.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../shell/main_shell.dart';
import 'requests_providers.dart';
import 'widgets/request_card.dart';

/// Tenant's requests, split into All / Viewings / Bookings tabs.
class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myViewingsProvider);
    ref.invalidate(myBookingsProvider);
    await Future.wait([
      ref.read(myViewingsProvider.future),
      ref.read(myBookingsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final viewings = ref.watch(myViewingsProvider);
    final bookings = ref.watch(myBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const AppDrawerButton(),
          title: const Text(S.myRequests),
          bottom: const TabBar(
            tabs: [
              Tab(text: S.tabAll),
              Tab(text: S.tabViewings),
              Tab(text: S.tabBookings),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllTab(viewings: viewings, bookings: bookings, colors: c,
                onRefresh: () => _refresh(ref)),
            _ViewingsTab(viewings: viewings, colors: c,
                onRefresh: () => _refresh(ref)),
            _BookingsTab(bookings: bookings, colors: c,
                onRefresh: () => _refresh(ref)),
          ],
        ),
      ),
    );
  }
}

/// Shared list scaffold: pull-to-refresh + padding.
class _RequestListView extends StatelessWidget {
  const _RequestListView({required this.onRefresh, required this.children});

  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavSpace),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

Widget _emptyRequests() => const EmptyState(
      icon: Icons.receipt_long_outlined,
      title: S.emptyRequests,
      message: S.emptyRequestsHint,
    );

/// Wraps an [AsyncValue] into the standard loading/error/empty/list flow.
Widget _asyncList<T>({
  required AsyncValue<List<T>> value,
  required Future<void> Function() onRefresh,
  required List<Widget> Function(List<T> items) toCards,
}) {
  return value.when(
    loading: () => const PropertyListSkeleton(count: 3),
    error: (e, _) => ErrorView(error: e, onRetry: onRefresh),
    data: (items) {
      if (items.isEmpty) return _emptyRequests();
      return _RequestListView(onRefresh: onRefresh, children: toCards(items));
    },
  );
}

class _ViewingsTab extends StatelessWidget {
  const _ViewingsTab({
    required this.viewings,
    required this.colors,
    required this.onRefresh,
  });

  final AsyncValue<List<ViewingRequest>> viewings;
  final SakanColors colors;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return _asyncList<ViewingRequest>(
      value: viewings,
      onRefresh: onRefresh,
      toCards: (items) =>
          [for (final r in items) RequestCard.viewing(r, c: colors)],
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({
    required this.bookings,
    required this.colors,
    required this.onRefresh,
  });

  final AsyncValue<List<BookingRequest>> bookings;
  final SakanColors colors;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return _asyncList<BookingRequest>(
      value: bookings,
      onRefresh: onRefresh,
      toCards: (items) =>
          [for (final r in items) RequestCard.booking(r, c: colors)],
    );
  }
}

/// The "All" tab merges both request types, newest first.
class _AllTab extends StatelessWidget {
  const _AllTab({
    required this.viewings,
    required this.bookings,
    required this.colors,
    required this.onRefresh,
  });

  final AsyncValue<List<ViewingRequest>> viewings;
  final AsyncValue<List<BookingRequest>> bookings;
  final SakanColors colors;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // Loading if either is still loading and neither has data yet.
    if (viewings.isLoading || bookings.isLoading) {
      return const PropertyListSkeleton(count: 3);
    }
    // Error only if both failed (partial data is still useful).
    if (viewings.hasError && bookings.hasError) {
      return ErrorView(error: viewings.error, onRetry: onRefresh);
    }

    final v = viewings.valueOrNull ?? const [];
    final b = bookings.valueOrNull ?? const [];
    if (v.isEmpty && b.isEmpty) return _emptyRequests();

    final entries = <_Entry>[
      for (final r in v)
        _Entry(r.createdAt, RequestCard.viewing(r, c: colors)),
      for (final r in b)
        _Entry(r.createdAt, RequestCard.booking(r, c: colors)),
    ]..sort((a, z) => z.epoch.compareTo(a.epoch));

    return _RequestListView(
      onRefresh: onRefresh,
      children: [for (final e in entries) e.card],
    );
  }
}

class _Entry {
  _Entry(this.timestamp, this.card);

  final DateTime? timestamp;
  final Widget card;

  int get epoch => timestamp?.millisecondsSinceEpoch ?? 0;
}
