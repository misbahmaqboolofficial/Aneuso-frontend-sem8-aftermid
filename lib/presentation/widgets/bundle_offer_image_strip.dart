import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Horizontal gap between bundle product images (~1 mm at 96 dpi).
const double bundleImageGapMm = 3.78;

/// Shows up to 3 product images side by side with [bundleImageGapMm] between them.
/// [imageUrl] may be a single URL/path or a JSON array of URLs (bundle mode).
class BundleOfferImageStrip extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final BoxFit fit;
  final Color? backgroundColor;
  final Widget? placeholder;

  const BundleOfferImageStrip({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.placeholder,
  });

  static List<String> parseBundleUrls(String? imageUrl, {int max = 3}) {
    if (imageUrl == null || imageUrl.trim().isEmpty) return [];
    final trimmed = imageUrl.trim();
    if (!trimmed.startsWith('[')) return [trimmed];
    try {
      final list = jsonDecode(trimmed) as List<dynamic>;
      return list
          .take(max)
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final base = AppConstants.baseUrl;
    if (base.endsWith('/') && url.startsWith('/')) {
      return '$base${url.substring(1)}';
    }
    if (!base.endsWith('/') && !url.startsWith('/')) {
      return '$base/$url';
    }
    return '$base$url';
  }

  @override
  Widget build(BuildContext context) {
    final urls = parseBundleUrls(imageUrl);
    final bg = backgroundColor ?? Colors.grey.shade100;
    final empty = placeholder ??
        Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
        );

    if (urls.isEmpty) {
      return Container(height: height, color: bg, child: empty);
    }

    final isJsonBundle = imageUrl!.trim().startsWith('[') && urls.length > 1;

    if (!isJsonBundle && urls.length == 1) {
      return Container(
        height: height,
        width: double.infinity,
        color: bg,
        child: Image.network(
          resolveUrl(urls.first),
          fit: fit,
          errorBuilder: (_, __, ___) => empty,
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < urls.length; i++) ...[
            if (i > 0) const SizedBox(width: bundleImageGapMm),
            Expanded(
              child: Image.network(
                resolveUrl(urls[i]),
                fit: fit,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
