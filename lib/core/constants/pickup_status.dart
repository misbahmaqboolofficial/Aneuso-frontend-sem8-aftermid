/// Canonical pickup_schedules.pickup_status_id values (aligned with API).
class PickupStatus {
  static const int scheduled = 1;
  static const int enRoute = 2;
  static const int completed = 3;
  static const int reachedDestination = 4;
  static const int cancelled = 6;

  static String label(int? id) {
    switch (id) {
      case scheduled:
        return 'Scheduled';
      case enRoute:
        return 'En Route';
      case reachedDestination:
        return 'Reached Destination';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static bool canStartTracking(int? id) =>
      id == scheduled || id == enRoute;

  static bool canMarkReached(int? id) => id == enRoute;

  static bool canConfirmPickup(int? id) =>
      id == reachedDestination || id == enRoute;

  static bool canLiveTrack(int? id) =>
      id == enRoute || id == reachedDestination;

  static bool isTerminal(int? id) => id == completed || id == cancelled;
}

/// Admin cleanup report_status_id values.
class ReportStatus {
  static const int assigned = 206;
  static const int enRoute = 207;
  static const int arrived = 205;
  static const int collected = 208;
  static const int cleaned = 174;

  static bool canLiveTrack(int? id) =>
      id == assigned || id == enRoute || id == arrived;
}

class TrackingTaskType {
  static const String industryPickup = 'industry_pickup';
  static const String adminCleanup = 'admin_cleanup';
}
