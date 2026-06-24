import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  final String _base = AppConstants.baseUrl;

  Map<String, String> get _headers {
    final token = StorageUtil.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> listUsers({
    required int userTypeId,
    String search = '',
  }) async {
    var uri = Uri.parse('$_base/chat/users?user_type_id=$userTypeId');
    if (search.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        'user_type_id': '$userTypeId',
        'search': search,
      });
    }
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendRequest(int recipientId) async {
    final res = await http.post(
      Uri.parse('$_base/chat/requests'),
      headers: _headers,
      body: jsonEncode({'recipient_id': recipientId}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listRequests({String direction = 'incoming'}) async {
    final res = await http.get(
      Uri.parse('$_base/chat/requests?direction=$direction'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> respondRequest(int requestId, String action) async {
    final res = await http.put(
      Uri.parse('$_base/chat/requests/$requestId/respond'),
      headers: _headers,
      body: jsonEncode({'action': action}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listConversations() async {
    final res = await http.get(
      Uri.parse('$_base/chat/conversations'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMessages(int conversationId) async {
    final res = await http.get(
      Uri.parse('$_base/chat/conversations/$conversationId/messages'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String text) async {
    final res = await http.post(
      Uri.parse('$_base/chat/conversations/$conversationId/messages'),
      headers: _headers,
      body: jsonEncode({'message_text': text}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteMessage(
    int conversationId,
    int messageId,
  ) async {
    final res = await http.delete(
      Uri.parse('$_base/chat/conversations/$conversationId/messages/$messageId'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listBlockedUsers() async {
    final res = await http.get(
      Uri.parse('$_base/chat/blocks'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> blockUser(int userId) async {
    final res = await http.post(
      Uri.parse('$_base/chat/blocks'),
      headers: _headers,
      body: jsonEncode({'blocked_user_id': userId}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unblockUser(int userId) async {
    final res = await http.delete(
      Uri.parse('$_base/chat/blocks/$userId'),
      headers: _headers,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
