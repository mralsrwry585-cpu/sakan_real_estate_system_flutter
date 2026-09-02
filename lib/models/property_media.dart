import '../core/config/app_config.dart';

/// A media item (currently only images) attached to a property.
class PropertyMedia {
  const PropertyMedia({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.isCover,
    required this.displayOrder,
  });

  final String id;
  final String url;
  final int mediaType; // 0 = Image
  final bool isCover;
  final int displayOrder;

  /// Resolves relative URLs against the API host; passes absolute URLs through.
  String get resolvedUrl {
    final u = url.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = u.startsWith('/') ? u : '/$u';
    return '$base$path';
  }

  factory PropertyMedia.fromJson(Map<String, dynamic> json) => PropertyMedia(
        id: (json['id'] ?? '').toString(),
        url: (json['url'] ?? '').toString(),
        mediaType: (json['mediaType'] as num?)?.toInt() ?? 0,
        isCover: json['isCover'] as bool? ?? false,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      );
}
