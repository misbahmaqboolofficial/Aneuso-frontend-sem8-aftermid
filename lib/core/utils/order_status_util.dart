import '../../services/order_service.dart';

/// Completed or closed orders the user may want to review later.
bool isPreviousOrder(Order order) {
  final status = order.orderStatusName.toLowerCase();
  const previousKeywords = [
    'delivered',
    'completed',
    'cancelled',
    'canceled',
    'failed',
    'refunded',
  ];
  return previousKeywords.any(status.contains);
}

bool isCurrentOrder(Order order) => !isPreviousOrder(order);

String orderStatusLabel(String rawStatus) {
  return rawStatus
      .replaceAll('order_', '')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
