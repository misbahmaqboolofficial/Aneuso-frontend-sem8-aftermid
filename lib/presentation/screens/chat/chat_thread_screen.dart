import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/data/services/chat_api_service.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/presentation/providers/auth_provider.dart';

final String _kScreenTitle = ScreenTitle.fromFile('chat_thread_screen.dart');

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserType,
    this.otherUserId,
  });

  final int conversationId;
  final String otherUserName;
  final String? otherUserType;
  final int? otherUserId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _api = ChatApiService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  Timer? _poll;
  int _myId = 0;
  int? _otherUserId;
  bool _iBlocked = false;
  bool _theyBlockedMe = false;

  bool get _isBlocked => _iBlocked || _theyBlockedMe;

  @override
  void initState() {
    super.initState();
    _otherUserId = widget.otherUserId;
    _myId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 0;
    _load();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final res = await _api.getMessages(widget.conversationId);
      if (res['success'] == true && mounted) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        final blockStatus = data['block_status'] as Map<String, dynamic>?;
        final otherUser = data['other_user'] as Map<String, dynamic>?;
        setState(() {
          _messages = List<dynamic>.from(data['messages'] ?? []);
          _loading = false;
          if (otherUser != null) {
            _otherUserId = otherUser['id'] is int
                ? otherUser['id'] as int
                : int.tryParse('${otherUser['id']}');
          }
          if (blockStatus != null) {
            _iBlocked = blockStatus['i_blocked'] == true;
            _theyBlockedMe = blockStatus['they_blocked_me'] == true;
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _blockUser() async {
    final uid = _otherUserId;
    if (uid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block user?'),
        content: Text(
          'Block ${widget.otherUserName}? They won\'t be able to message you.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await _api.blockUser(uid);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'User blocked')),
      );
      await _load(silent: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not block')),
      );
    }
  }

  Future<void> _unblockUser() async {
    final uid = _otherUserId;
    if (uid == null) return;

    final res = await _api.unblockUser(uid);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
      await _load(silent: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not unblock')),
      );
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final rawId = message['id'];
    final messageId = rawId is int ? rawId : int.tryParse('$rawId');
    if (messageId == null) return;

    final preview = (message['message_text']?.toString() ?? '').trim();
    final snippet = preview.length > 60 ? '${preview.substring(0, 60)}…' : preview;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message?'),
        content: Text(
          snippet.isEmpty
              ? 'This message will be removed for everyone in this chat.'
              : 'Delete "$snippet"?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await _api.deleteMessage(widget.conversationId, messageId);
    if (!mounted) return;
    if (res['success'] == true) {
      await _load(silent: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not delete message')),
      );
    }
  }

  Future<void> _send() async {
    if (_isBlocked) return;
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _input.clear();
    try {
      final res = await _api.sendMessage(widget.conversationId, text);
      if (res['success'] == true && mounted) {
        await _load(silent: true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? 'Failed to send')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _kScreenTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              [
                widget.otherUserName,
                if (widget.otherUserType != null) widget.otherUserType!,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        toolbarHeight: 56,
        backgroundColor: const Color(0xFF9B5DE0),
        foregroundColor: Colors.white,
        actions: [
          if (_otherUserId != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'block') _blockUser();
                if (value == 'unblock') _unblockUser();
              },
              itemBuilder: (ctx) => [
                if (_iBlocked)
                  const PopupMenuItem(
                    value: 'unblock',
                    child: Row(
                      children: [
                        Icon(Icons.lock_open, size: 20),
                        SizedBox(width: 8),
                        Text('Unblock'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Block user', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isBlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.red.shade50,
              child: Text(
                _iBlocked
                    ? 'You blocked this user. Unblock to send messages.'
                    : 'This user has blocked you.',
                style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9B5DE0)),
                  )
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Say hello! Messages stay in this chat.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final m = Map<String, dynamic>.from(_messages[i] as Map);
                          final sid = m['sender_id'];
                          final senderId = sid is int ? sid : int.tryParse('$sid') ?? 0;
                          return _MessageBubble(
                            message: m,
                            isMe: senderId == _myId,
                            onDelete: senderId == _myId
                                ? () => _deleteMessage(m)
                                : null,
                          );
                        },
                      ),
          ),
          if (!_isBlocked) _composer(),
        ],
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message…',
                filled: true,
                fillColor: const Color(0xFFF9F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF9B5DE0),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onDelete,
  });
  final Map<String, dynamic> message;
  final bool isMe;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = message['message_text']?.toString() ?? '';
    final raw = message['created_at']?.toString() ?? '';
    final readAt = message['read_at'];
    String timeLabel = raw;
    if (raw.length >= 16) timeLabel = raw.substring(11, 16);

    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF9B5DE0) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : const Color(0xFF333333),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  readAt != null ? Icons.done_all : Icons.check,
                  size: 14,
                  color: readAt != null ? const Color(0xFF00BFFF) : Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onDelete,
        child: bubble,
      ),
    );
  }
}
