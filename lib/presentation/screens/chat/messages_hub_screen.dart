//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/data/services/chat_api_service.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:flutter/material.dart';
import 'chat_thread_screen.dart';

/// Facebook-style messaging: find users, send requests, chat when accepted.
class MessagesHubScreen extends StatefulWidget {
  const MessagesHubScreen({super.key});

  @override
  State<MessagesHubScreen> createState() => _MessagesHubScreenState();
}

class _MessagesHubScreenState extends State<MessagesHubScreen>
    with SingleTickerProviderStateMixin {
  final _api = ChatApiService();
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openThread({
    required int conversationId,
    required String name,
    String? type,
    int? otherUserId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatThreadScreen(
          conversationId: conversationId,
          otherUserName: name,
          otherUserType: type,
          otherUserId: otherUserId,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6F38C5),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: isNarrowPhone(context),
          tabAlignment: isNarrowPhone(context) ? TabAlignment.start : TabAlignment.fill,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: isCompactPhone(context) ? 'Chat' : 'Chats'),
            const Tab(text: 'Requests'),
            Tab(text: isCompactPhone(context) ? 'Find' : 'Find People'),
            const Tab(text: 'Blocked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ChatsTab(api: _api, onOpen: _openThread),
          _RequestsTab(api: _api, onAccepted: () => _tabs.animateTo(0)),
          _FindPeopleTab(api: _api, onOpenChat: _openThread),
          _BlockedTab(api: _api),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatefulWidget {
  const _ChatsTab({required this.api, required this.onOpen});
  final ChatApiService api;
  final void Function({
    required int conversationId,
    required String name,
    String? type,
    int? otherUserId,
  }) onOpen;

  @override
  State<_ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<_ChatsTab> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.listConversations();
      if (res['success'] == true && mounted) {
        setState(() {
          _items = List<dynamic>.from(res['data'] ?? []);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B5DE0)));
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                'No chats yet.\nFind people and send a chat request!',
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF6F38C5).withOpacity(0.5)),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = Map<String, dynamic>.from(_items[i] as Map);
          final unread = int.tryParse('${c['unread_count']}') ?? 0;
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF9B5DE0).withOpacity(0.2),
              child: Text(
                (c['other_user_name'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF9B5DE0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              c['other_user_name'] ?? 'User',
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            subtitle: Text(
              c['last_message_text']?.toString() ?? 'Start chatting',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: unread > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF9B5DE0),
                    child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  )
                : null,
            onTap: () {
              final cid = c['id'] is int ? c['id'] as int : int.parse('${c['id']}');
              final otherId = c['other_user_id'];
              widget.onOpen(
                conversationId: cid,
                name: c['other_user_name']?.toString() ?? 'Chat',
                type: c['other_user_type_name']?.toString(),
                otherUserId: otherId is int ? otherId : int.tryParse('$otherId'),
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestsTab extends StatefulWidget {
  const _RequestsTab({required this.api, required this.onAccepted});
  final ChatApiService api;
  final VoidCallback onAccepted;

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  bool _showIncoming = true; // true = Incoming, false = Sent
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final direction = _showIncoming ? 'incoming' : 'outgoing';
      final res = await widget.api.listRequests(direction: direction);
      if (mounted) {
        setState(() {
          _items = res['success'] == true ? List.from(res['data'] ?? []) : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(int id, String action) async {
    final res = await widget.api.respondRequest(id, action);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'accept' ? 'Request accepted' : 'Request rejected')),
      );
      if (action == 'accept') widget.onAccepted();
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_showIncoming) {
                        setState(() => _showIncoming = true);
                        _load();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showIncoming ? const Color(0xFF9B5DE0) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call_received_rounded,
                            size: 18,
                            color: _showIncoming ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Incoming',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _showIncoming ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_showIncoming) {
                        setState(() => _showIncoming = false);
                        _load();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showIncoming ? const Color(0xFF9B5DE0) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call_made_rounded,
                            size: 18,
                            color: !_showIncoming ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !_showIncoming ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // List content
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF9B5DE0)))
              : _items.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  _showIncoming ? Icons.inbox_rounded : Icons.send_rounded,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _showIncoming
                                      ? 'No incoming requests'
                                      : 'No sent requests',
                                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final m = Map<String, dynamic>.from(_items[i] as Map);
                          final id = m['id'] is int ? m['id'] as int : int.parse('${m['id']}');
                          // Pending card
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 1,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFDCFFA),
                                child: Text(
                                  (m['other_user_name'] ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF450693),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                m['other_user_name'] ?? 'User',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                m['other_user_type_name'] ?? '',
                                style: const TextStyle(color: Color(0xFFA555EC), fontSize: 13),
                              ),
                              trailing: _showIncoming
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle, color: Color(0xFF6F38C5)),
                                          tooltip: 'Accept',
                                          onPressed: () => _respond(id, 'accept'),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.cancel, color: const Color(0xFF9B5DE0).withOpacity(0.4)),
                                          tooltip: 'Reject',
                                          onPressed: () => _respond(id, 'reject'),
                                        ),
                                      ],
                                    )
                                  : Chip(
                                      label: const Text(
                                        'Pending',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF450693)),
                                      ),
                                      backgroundColor: const Color(0xFFFDCFFA),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                            ),
                          ); // end Pending card
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _FindPeopleTab extends StatefulWidget {
  const _FindPeopleTab({required this.api, required this.onOpenChat});
  final ChatApiService api;
  final void Function({
    required int conversationId,
    required String name,
    String? type,
    int? otherUserId,
  }) onOpenChat;

  @override
  State<_FindPeopleTab> createState() => _FindPeopleTabState();
}

class _FindPeopleTabState extends State<_FindPeopleTab> {
  static const _types = [
    (1, 'Industry'),
    (2, 'Driver'),
    (3, 'Citizen'),
    (4, 'Admin'),
  ];

  int _selectedType = 2;
  final _search = TextEditingController();
  List<dynamic> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.listUsers(
        userTypeId: _selectedType,
        search: _search.text.trim(),
      );
      if (res['success'] == true && mounted) {
        setState(() {
          _users = List<dynamic>.from(res['data'] ?? []);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest(Map<String, dynamic> u) async {
    final uid = u['id'] is int ? u['id'] as int : int.parse('${u['id']}');
    final res = await widget.api.sendRequest(uid);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat request sent')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not send request')),
      );
    }
  }

  Future<void> _blockUser(Map<String, dynamic> u) async {
    final uid = u['id'] is int ? u['id'] as int : int.parse('${u['id']}');
    final name = u['full_name']?.toString() ?? 'this user';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block user?'),
        content: Text(
          'Block $name? They won\'t be able to message you or send chat requests.',
        ),
        actions: [
          // Cancel button
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), // end Cancel button
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await widget.api.blockUser(uid);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'User blocked')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not block user')),
      );
    }
  }

  Widget _actionButton(Map<String, dynamic> u) {
    final status = u['connection_status']?.toString() ?? 'none';
    final convId = u['conversation_id'];
    final name = u['full_name']?.toString() ?? 'User';
    final type = u['user_type_name']?.toString();
    final uid = u['id'] is int ? u['id'] as int : int.parse('${u['id']}');

    if (status == 'blocked') {
      final iBlocked = u['i_blocked'] == true;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              iBlocked ? 'Blocked' : 'Blocked you',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
          if (iBlocked)
            IconButton(
              icon: const Icon(Icons.lock_open, size: 20),
              tooltip: 'Unblock',
              onPressed: () async {
                final res = await widget.api.unblockUser(uid);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res['success'] == true
                          ? (res['message']?.toString() ?? 'Unblocked')
                          : (res['message']?.toString() ?? 'Failed'),
                    ),
                  ),
                );
                if (res['success'] == true) _load();
              },
            ),
        ],
      );
    }
    if (status == 'accepted' && convId != null) {
      final cid = convId is int ? convId : int.parse('$convId');
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => widget.onOpenChat(
              conversationId: cid,
              name: name,
              type: type,
              otherUserId: uid,
            ),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6F38C5)),
            child: const Text('Chat'),
          ),
          IconButton(
            icon: Icon(Icons.block, color: Colors.red.shade400, size: 22),
            tooltip: 'Block',
            onPressed: () => _blockUser(u),
          ),
        ],
      );
    }
    if (status == 'pending') {
      final iAm = u['i_am_requester'] == true;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: iAm ? const Color(0xFF450693) : const Color(0xFFFDCFFA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          iAm ? 'Request sent' : 'Respond in Requests',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: iAm ? Colors.white : const Color(0xFF450693),
          ),
        ),
      );
    }
    if (status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD78FEE).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Rejected',
          style: TextStyle(fontSize: 12, color: Color(0xFF450693)),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Request button
        OutlinedButton(
          onPressed: () => _sendRequest(u),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8A39E1),
            side: const BorderSide(color: Color(0xFF8A39E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Request'),
        ), // end Request button
        IconButton(
          icon: Icon(Icons.block, color: Colors.red.shade300, size: 22),
          tooltip: 'Block',
          onPressed: () => _blockUser(u),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'User type',
                  labelStyle: const TextStyle(color: Color(0xFF8A39E1)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF9B5DE0), width: 2),
                  ),
                ),
                items: _types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.$1,
                        child: Text(t.$2),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedType = v);
                    _load();
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFA555EC)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF9B5DE0), width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _load(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF9B5DE0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF9B5DE0)),
                )
              : _users.isEmpty
                  ? Center(
                      child: Text(
                        'Select a type and tap refresh to see users',
                        style: TextStyle(color: const Color(0xFF6F38C5).withOpacity(0.5)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final u = Map<String, dynamic>.from(_users[i] as Map);
                        // Card card
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFDCFFA),
                              child: Text(
                                (u['full_name'] ?? '?')[0].toUpperCase(),
                                style: const TextStyle(color: Color(0xFF450693), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              u['full_name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              u['user_type_name'] ?? '',
                            ),
                            isThreeLine: false,
                            trailing: _actionButton(u),
                          ),
                        ); // end Card card
                      },
                    ),
        ),
      ],
    );
  }
}

class _BlockedTab extends StatefulWidget {
  const _BlockedTab({required this.api});
  final ChatApiService api;

  @override
  State<_BlockedTab> createState() => _BlockedTabState();
}

class _BlockedTabState extends State<_BlockedTab> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.listBlockedUsers();
      if (mounted) {
        setState(() {
          _items = res['success'] == true ? List.from(res['data'] ?? []) : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unblock(Map<String, dynamic> u) async {
    final uid = u['id'] is int ? u['id'] as int : int.parse('${u['id']}');
    final name = u['full_name']?.toString() ?? 'User';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock user?'),
        content: Text('Unblock $name? They will be able to send you chat requests again.'),
        actions: [
          // Cancel button
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), // end Cancel button
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await widget.api.unblockUser(uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res['success'] == true
              ? (res['message']?.toString() ?? 'Unblocked')
              : (res['message']?.toString() ?? 'Failed'),
        ),
      ),
    );
    if (res['success'] == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B5DE0)));
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.block, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No blocked users',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final u = Map<String, dynamic>.from(_items[i] as Map);
          // Unblock card
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Text(
                  (u['full_name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                u['full_name'] ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(u['user_type_name']?.toString() ?? ''),
              trailing: OutlinedButton(
                onPressed: () => _unblock(u),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6F38C5)),
                child: const Text('Unblock'),
              ),
            ),
          ); // end Unblock card
        },
      ),
    );
  }
}
