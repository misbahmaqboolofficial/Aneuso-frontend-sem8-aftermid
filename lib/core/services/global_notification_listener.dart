import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/local_notification_service.dart';
import '../utils/storage_util.dart';

/// Listens for new notifications app-wide and shows local alerts on any screen.
class GlobalNotificationListener extends StatefulWidget {
  final int userId;
  final Widget child;

  const GlobalNotificationListener({
    super.key,
    required this.userId,
    required this.child,
  });

  @override
  State<GlobalNotificationListener> createState() =>
      _GlobalNotificationListenerState();
}

class _GlobalNotificationListenerState extends State<GlobalNotificationListener> {
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  Timer? _pollTimer;
  int? _lastSeenNotificationId;
  bool _readyToAlert = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(GlobalNotificationListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _stopListening();
      _lastSeenNotificationId = null;
      _readyToAlert = false;
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    await _seedLatestNotificationId();
    if (!mounted) return;
    setState(() => _readyToAlert = true);
    _startListening();
  }

  Future<void> _seedLatestNotificationId() async {
    try {
      final latest = await _fetchLatestNotification();
      if (latest == null) return;
      final id = _notificationId(latest);
      if (id != null) {
        _lastSeenNotificationId = id;
      }
    } catch (_) {
      // Polling/realtime will still work; may show one existing alert on first event.
    }
  }

  void _startListening() {
    _realtimeSubscription?.cancel();
    _pollTimer?.cancel();

    debugPrint(
      'GlobalNotificationListener: listening for user ${widget.userId}',
    );

    _realtimeSubscription = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_user_id', widget.userId)
        .listen(
      (List<Map<String, dynamic>> data) {
        if (data.isEmpty) return;
        final latest = data.last;
        _onNotification(latest);
      },
      onError: (error) {
        debugPrint('GlobalNotificationListener realtime error: $error');
      },
    );

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollNotifications();
    });
  }

  Future<void> _pollNotifications() async {
    try {
      final latest = await _fetchLatestNotification();
      if (latest != null) {
        _onNotification(latest);
      }
    } catch (_) {
      // Inbox still works if polling fails.
    }
  }

  Future<Map<String, dynamic>?> _fetchLatestNotification() async {
    final token = StorageUtil.getToken();
    if (token == null) return null;

    final res = await http
        .get(
          Uri.parse('${AppConstants.baseUrl}/notifications'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) return null;

    final jsonBody = jsonDecode(res.body);
    if (jsonBody['success'] != true) return null;

    final List<dynamic> data = jsonBody['data'] ?? [];
    if (data.isEmpty) return null;

    return data.first as Map<String, dynamic>;
  }

  int? _notificationId(Map<String, dynamic> notification) {
    final id = notification['id'];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? '');
  }

  void _onNotification(Map<String, dynamic> notification) {
    if (!_readyToAlert) return;

    final id = _notificationId(notification);
    if (id == null) return;

    if (_lastSeenNotificationId != null && id <= _lastSeenNotificationId!) {
      return;
    }

    _lastSeenNotificationId = id;

    LocalNotificationService.showNotification(
      id: id % 100000,
      title: notification['title']?.toString() ?? 'New Notification',
      body: notification['message']?.toString() ??
          notification['body']?.toString() ??
          '',
    );
  }

  void _stopListening() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
