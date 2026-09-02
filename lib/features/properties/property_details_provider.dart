import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/property.dart';
import '../../providers/app_providers.dart';

/// Full property detail by id. Auto-disposed so re-entering the page fetches
/// fresh data (e.g. updated view count) and memory is freed on exit.
final propertyDetailsProvider =
    FutureProvider.autoDispose.family<PropertyDetails, String>((ref, id) {
  return ref.watch(propertyRepositoryProvider).getProperty(id);
});
