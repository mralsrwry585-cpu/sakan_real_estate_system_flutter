import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/property.dart';
import '../../providers/app_providers.dart';

/// Featured rail: a few most-viewed available properties.
final featuredPropertiesProvider =
    FutureProvider<List<PropertyListItem>>((ref) {
  return ref.watch(propertyRepositoryProvider).getFeatured();
});

/// "Latest" list on Home: first page of newest available properties.
final latestPropertiesProvider =
    FutureProvider<List<PropertyListItem>>((ref) async {
  final result = await ref.watch(propertyRepositoryProvider).getLatest();
  return result.items;
});
