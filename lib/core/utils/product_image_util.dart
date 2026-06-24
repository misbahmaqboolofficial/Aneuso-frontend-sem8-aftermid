import '../constants/app_constants.dart';

const Map<String, String> kProductImageHeaders = {
  'User-Agent': 'Mozilla/5.0 (compatible; AneusoApp/1.0)',
  'Accept': 'image/*',
};

bool isPlaceholderProductImage(String? raw) {
  if (raw == null || raw.trim().isEmpty) return true;
  final value = raw.trim().toLowerCase();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return false;
  }
  // Legacy seed placeholders like url1-C01-P1
  return RegExp(r'^url[\w-]*$').hasMatch(value);
}

/// Resolves product image paths from the API into loadable network URLs.
String? resolveProductImageUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  if (isPlaceholderProductImage(raw)) return null;
  final value = raw.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final origin = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
  if (value.startsWith('/')) {
    return '$origin$value';
  }
  return '$origin/$value';
}

List<String> resolveProductImages(List<String>? images) {
  if (images == null || images.isEmpty) return const [];
  return images
      .map(resolveProductImageUrl)
      .whereType<String>()
      .where((url) => url.isNotEmpty)
      .toList();
}
