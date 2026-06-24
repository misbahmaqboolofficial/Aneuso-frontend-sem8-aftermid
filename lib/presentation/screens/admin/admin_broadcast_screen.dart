import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/storage_util.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('admin_broadcast_screen.dart');

/// Admin compose screen for broadcast notifications to clients or drivers.
class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _recipientTypeId = 1;
  bool _isSending = false;

  static const _recipients = [
    (1, 'All users'),
    (2, 'Industry clients'),
    (3, 'Drivers'),
    (4, 'Citizens'),
    (5, 'Admins'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    setState(() => _isSending = true);
    try {
      final token = StorageUtil.getToken();
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/system/broadcast'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipient_type_id': _recipientTypeId,
          'title': title,
          'message': message,
          'priority_level_id': 2,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Notification sent')),
          );
          _titleController.clear();
          _messageController.clear();
        }
      } else {
        throw Exception(body['message'] ?? 'Failed to send');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(_kScreenTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: _recipientTypeId,
              decoration: InputDecoration(
                labelText: 'Send to',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _recipients
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.$1,
                      child: Text(r.$2),
                    ),
                  )
                  .toList(),
              onChanged: _isSending ? null : (v) => setState(() => _recipientTypeId = v ?? 1),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => FormValidators.required(v, field: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => FormValidators.description(v, minLength: 5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSending ? null : _send,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSending ? 'Sending…' : 'Send broadcast'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6F38C5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
