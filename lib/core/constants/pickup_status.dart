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

/// Admin cleanup display labels (driver submit vs admin verify).
class CleanupStatusUtil {
  static bool isDriverPendingAdminVerification({
    required int? reportStatusId,
    dynamic driverMarkedCompleteAt,
  }) {
    if (driverMarkedCompleteAt == null ||
        driverMarkedCompleteAt.toString().isEmpty) {
      return false;
    }
    final id = reportStatusId ?? 0;
    return id != ReportStatus.collected && id != ReportStatus.cleaned;
  }

  static bool isAdminVerifiedComplete(int? reportStatusId) {
    final id = reportStatusId ?? 0;
    return id == ReportStatus.collected || id == ReportStatus.cleaned;
  }

  static String adminDisplayLabel({
    required int? reportStatusId,
    dynamic driverMarkedCompleteAt,
    String? fallbackName,
  }) {
    if (isAdminVerifiedComplete(reportStatusId)) {
      if (reportStatusId == ReportStatus.cleaned) return 'Area Cleaned';
      return 'Completed';
    }
    if (isDriverPendingAdminVerification(
      reportStatusId: reportStatusId,
      driverMarkedCompleteAt: driverMarkedCompleteAt,
    )) {
      return 'Completed marked by driver';
    }
    return _workflowStatusName(reportStatusId, fallbackName);
  }

  static String _workflowStatusName(int? id, [String? fallbackName]) {
    switch (id) {
      case 170:
      case 171:
        return 'Pending Review';
      case 172:
        return 'Report Approved';
      case 206:
        return 'Driver Assigned';
      case 207:
        return 'Driver on the Way';
      case 205:
        return 'Cleaning Started';
      case 208:
        return 'Completed';
      case 174:
        return 'Area Cleaned';
      case 204:
        return 'Collected / Funding Started';
      default:
        if (fallbackName != null && fallbackName.isNotEmpty) {
          return fallbackName
              .replaceFirst('report_status_', '')
              .replaceAll('_', ' ');
        }
        return 'Unknown';
    }
  }

  static int stepperStep({
    required int? reportStatusId,
    dynamic driverMarkedCompleteAt,
  }) {
    final statusId = reportStatusId ?? 0;
    if (isDriverPendingAdminVerification(
      reportStatusId: statusId,
      driverMarkedCompleteAt: driverMarkedCompleteAt,
    )) {
      return 4;
    }
    if (statusId == 172) return 1;
    if (statusId == 206) return 2;
    if (statusId == 207) return 3;
    if (statusId == 205) return 4;
    if (statusId == 208 || statusId == 174) return 5;
    return 0;
  }
}

class TrackingTaskType {
  static const String industryPickup = 'industry_pickup';
  static const String adminCleanup = 'admin_cleanup';
}
