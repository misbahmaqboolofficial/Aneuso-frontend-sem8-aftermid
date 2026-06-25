import '../../services/order_service.dart';

/// Calendar-day age of an order in the user's local timezone (0 = placed today).
int orderAgeInDays(Order order) {
  final local = order.createdAt.toLocal();
  final orderDay = DateTime(local.year, local.month, local.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(orderDay).inDays;
}

/// Orders placed 3+ calendar days ago.
bool isPreviousOrder(Order order) => orderAgeInDays(order) >= 3;

/// Orders placed today or within the last 2 days (not yet 3 days old).
bool isCurrentOrder(Order order) => orderAgeInDays(order) < 3;

String orderStatusLabel(String rawStatus) {
  return rawStatus
      .replaceAll('order_', '')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
