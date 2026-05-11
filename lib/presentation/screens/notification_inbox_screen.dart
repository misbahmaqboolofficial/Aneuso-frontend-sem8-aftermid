import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({Key? key}) : super(key: key);

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  List notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchNotifications({bool quiet = false}) async {
    if (!quiet) setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['success']) {
        if (mounted) {
          setState(() {
            notifications = result['data'];
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      await http.put(
        Uri.parse('${AppConstants.baseUrl}/notifications/$id/read'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _fetchNotifications(quiet: true);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      await http.put(
        Uri.parse('${AppConstants.baseUrl}/notifications/read-all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _fetchNotifications();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/notifications/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          notifications.removeWhere((n) => n['id'] == id);
        });
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDCFFA).withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Color(0xFF4E56C0), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF4E56C0)),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      bool isRead = notification['read_at'] != null;
                      return _buildNotificationCard(notification, isRead);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isRead) {
    return Card(
      elevation: isRead ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isRead ? Colors.white.withOpacity(0.8) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isRead ? Colors.grey : const Color(0xFF4E56C0)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(notification['notification_type_id']),
            color: isRead ? Colors.grey : const Color(0xFF4E56C0),
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            color: isRead ? Colors.grey[700] : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: TextStyle(color: isRead ? Colors.grey : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification['created_at']),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
          onPressed: () => _deleteNotification(notification['id']),
        ),
        onTap: () {
          if (!isRead) _markAsRead(notification['id']);
        },
      ),
    );
  }

  IconData _getIconForType(int? typeId) {
    switch (typeId) {
      case 175: return Icons.warning_rounded; // alert
      case 176: return Icons.info_rounded; // update
      case 178: return Icons.alarm_rounded; // reminder
      default: return Icons.notifications;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }
}
