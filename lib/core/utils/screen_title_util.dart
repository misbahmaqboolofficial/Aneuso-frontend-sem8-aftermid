/// Converts a screen dart file name into its AppBar title.
///
/// Examples:
/// - `admin_cleanup_dashboard_screen.dart` → `Admin Cleanup Dashboard`
/// - `AdminCleanupDashboard.dart` → `Admin Cleanup Dashboard`
/// - `schedule_pickup.dart` → `Schedule Pickup`
class ScreenTitle {
  ScreenTitle._();

  static String fromFile(String fileName) {
    var stem = fileName.replaceAll(RegExp(r'\.dart$'), '');
    stem = stem.replaceAll(RegExp(r'_screen$', caseSensitive: false), '');
    stem = stem.replaceAll(RegExp(r'Screen$'), '');

    if (stem.contains('_')) {
      return stem
          .split('_')
          .where((part) => part.isNotEmpty)
          .map(_capitalizeWord)
          .join(' ');
    }

    return _camelCaseToTitle(stem);
  }

  static String _camelCaseToTitle(String input) {
    final spaced = input.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();

    if (spaced.isEmpty) return input;

    return spaced
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(_capitalizeWord)
        .join(' ');
  }

  static String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    if (word.length == 1) return word.toUpperCase();
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
