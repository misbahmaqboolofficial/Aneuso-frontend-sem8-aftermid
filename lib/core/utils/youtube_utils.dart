/// Utility class for YouTube video operations
class YoutubeUtils {
  /// Extract video ID from various YouTube URL formats
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;

    try {
      // Skip placeholder URLs
      if (url.contains('example') || url.contains('placeholder')) {
        return null;
      }

      // Format: https://www.youtube.com/watch?v=VIDEO_ID
      if (url.contains('youtube.com') && url.contains('watch?v=')) {
        final videoId = url.split('watch?v=').last.split('&').first;
        if (videoId.isNotEmpty) return videoId;
      }

      // Format: https://youtu.be/VIDEO_ID
      if (url.contains('youtu.be/')) {
        final videoId = url.split('youtu.be/').last.split('?').first;
        if (videoId.isNotEmpty) return videoId;
      }

      // Format: just the video ID
      if (!url.contains('/') && !url.contains('?') && url.length == 11) {
        return url;
      }
    } catch (e) {
      print('Error extracting video ID: $e');
    }

    return null;
  }

  /// Get YouTube thumbnail URL for a video
  /// Returns the highest quality available thumbnail
  static String getThumbnailUrl(String videoId) {
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  /// Get alternative thumbnail URLs in order of quality
  static List<String> getThumbnailUrlAlternatives(String videoId) {
    if (videoId.isEmpty) return [];
    return [
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      'https://img.youtube.com/vi/$videoId/sddefault.jpg',
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
      'https://img.youtube.com/vi/$videoId/default.jpg',
    ];
  }

  /// Check if URL is a valid YouTube URL
  static bool isYoutubeUrl(String url) {
    return extractVideoId(url) != null;
  }
}
