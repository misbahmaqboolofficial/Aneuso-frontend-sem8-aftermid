import 'dart:async';
import 'dart:convert';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_ui.dart';

final String _kScreenTitle = ScreenTitle.fromFile('notification_inbox_screen.dart');

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            pageHorizontalPadding(context),
            16,
            pageHorizontalPadding(context) * 0.6,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppSectionTitle(_kScreenTitle, subtitle: 'Stay up to date'),
              ),
              IconButton(
                tooltip: 'Mark all as read',
                onPressed: _markAllAsRead,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDeep.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.done_all, color: AppColors.primaryDeep, size: 20),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          pageHorizontalPadding(context),
                          0,
                          pageHorizontalPadding(context),
                          16,
                        ),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final isRead = notification['read_at'] != null;
                          return _buildNotificationCard(notification, isRead);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.lilac.withValues(alpha: 0.6),
                  AppColors.surfaceMuted,
                ],
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          const AppGradientText(
            'All caught up',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'No notifications yet',
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isRead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface.withValues(alpha: 0.85) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead ? AppColors.borderSoft : AppColors.primary.withValues(alpha: 0.25),
        ),
        boxShadow: isRead ? null : [AppColors.softShadow(AppColors.primaryLight)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isRead
                ? LinearGradient(
                    colors: [Colors.grey.withValues(alpha: 0.15), Colors.grey.withValues(alpha: 0.08)],
                  )
                : AppColors.buttonGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(notification['notification_type_id']),
            color: isRead ? AppColors.textMuted : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
            color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: TextStyle(
                color: isRead ? AppColors.textMuted : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(notification['created_at']),
              style: TextStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.9)),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted.withValues(alpha: 0.7)),
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
      case 175:
        return Icons.warning_rounded;
      case 176:
        return Icons.info_rounded;
      case 178:
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_rounded;
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
