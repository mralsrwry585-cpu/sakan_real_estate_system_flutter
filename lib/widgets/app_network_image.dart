import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/enums.dart';

/// Network image with a shimmer placeholder and a branded fallback.
///
/// Falls back to a typed placeholder (property-type icon) when [url] is null or
/// fails to load — no broken image glyphs.
///
/// On the web preview it uses [Image.network] (an `<img>` element) instead of
/// [CachedNetworkImage]: the latter fetches bytes via XHR, which browsers block
/// for cross-origin hosts (CORS), whereas an `<img>` renders them fine. On
/// mobile it keeps [CachedNetworkImage] for disk caching. This is why an image
/// with a valid URL can appear on Android yet fall back to an icon in Chrome.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.propertyType,
  });

  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final PropertyType? propertyType;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return _fallback(c);

    if (kIsWeb) {
      return Image.network(
        trimmed,
        fit: fit,
        gaplessPlayback: true,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _shimmer(c),
        errorBuilder: (_, __, ___) => _fallback(c),
      );
    }

    return CachedNetworkImage(
      imageUrl: trimmed,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => _shimmer(c),
      errorWidget: (_, __, ___) => _fallback(c),
    );
  }

  Widget _shimmer(SakanColors c) => Shimmer.fromColors(
        baseColor: c.muted,
        highlightColor: c.surface2,
        child: Container(color: c.muted),
      );

  Widget _fallback(SakanColors c) => Container(
        color: c.muted,
        alignment: Alignment.center,
        child: Icon(
          propertyType?.icon ?? fallbackIcon,
          size: 42,
          color: c.mutedForeground.tint(0.5),
        ),
      );
}
