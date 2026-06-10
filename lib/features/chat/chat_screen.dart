import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

const String _baseUrl = 'https://healthsync-ai-y60b.onrender.com';

class _C {
  static const bg = Color(0xFFF5F0FD);
  static const border = Color(0xFFE6D8F8);
  static const purple100 = Color(0xFFF0E6FB);
  static const purple400 = Color(0xFFC97FD4);
  static const purple700 = Color(0xFF6040A8);
  static const userBubble = Color(0xFFC97FD4);
  static const aiBubble = Colors.white;
  static const textMain = Color(0xFF5A3D8A);
  static const textHint = Color(0xFFCCBBEE);
}

class _Message {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  _Message({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory _Message.fromJson(Map<String, dynamic> json) {
    return _Message(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
    );
  }
}

class _ChatSession {
  final String id;
  String? serverId;
  String title;
  List<_Message> messages;
  DateTime updatedAt;

  _ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.serverId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _ChatSession.fromJson(Map<String, dynamic> json) {
    final msgsJson = json['messages'] as List<dynamic>? ?? [];

    return _ChatSession(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: json['serverId'] as String?,
      title: json['title'] as String? ?? 'Cuộc trò chuyện',
      messages: msgsJson
          .map((e) => _Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _storageKey = 'chat_sessions_v3';
  static const String _apiKey = 'AIzaSyBQDVsE-8te0Uu_ow9iWZzO4StqyvxqZwY';

  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  bool _isLoading = false;
  bool _isLoadingSessions = true;

  final List<_ChatSession> _sessions = [];
  _ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    try {
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;

        _sessions
          ..clear()
          ..addAll(
            decoded.map(
              (e) => _ChatSession.fromJson(e as Map<String, dynamic>),
            ),
          );

        _sortSessions();
      }
    } catch (_) {
      _sessions.clear();
    }

    if (_sessions.isEmpty) {
      _sessions.add(_newSession());
      await _saveSessions();
    }

    if (mounted) {
      setState(() {
        _currentSession = _sessions.first;
        _isLoadingSessions = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_sessions.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<String?> _createChatSessionApi() async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        _showSnack('Không có token đăng nhập');
        return null;
      }

      final res = await http.post(
        Uri.parse('$_baseUrl/api/chat/session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return '${data['id']}';
      }

      _showSnack('Lỗi tạo phiên chat ${res.statusCode}: ${res.body}');
      return null;
    } catch (e) {
      _showSnack('Lỗi kết nối chat: $e');
      return null;
    }
  }

  Future<void> _saveChatMessageApi({
    required String sessionId,
    required String content,
    required String sender,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) return;

      await http.post(
        Uri.parse('$_baseUrl/api/chat/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'content': content,
          'sender': sender,
        }),
      );
    } catch (_) {}
  }

  void _sortSessions() {
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  _ChatSession _newSession() {
    final now = DateTime.now();

    return _ChatSession(
      id: now.microsecondsSinceEpoch.toString(),
      title: 'Cuộc trò chuyện mới',
      updatedAt: now,
      messages: [
        _Message(
          text:
              'Xin chào 👋\nMình là HealthSync AI.\nBạn cần hỗ trợ gì hôm nay?',
          isUser: false,
          createdAt: now,
        ),
      ],
    );
  }

  Future<void> _createNewSession() async {
    final session = _newSession();

    setState(() {
      _sessions.insert(0, session);
      _currentSession = session;
    });

    await _saveSessions();
    _scrollToBottom();
  }

  Future<void> _deleteSession(String sessionId) async {
    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);

      if (_sessions.isEmpty) {
        final session = _newSession();
        _sessions.add(session);
        _currentSession = session;
      } else if (_currentSession?.id == sessionId) {
        _currentSession = _sessions.first;
      }
    });

    await _saveSessions();
    _scrollToBottom();
  }

  Future<String> _getGeminiResponse(String prompt) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Bạn là HealthSync AI. Hãy trả lời bằng tiếng Việt ngắn gọn, dễ hiểu.\n\nCâu hỏi: $prompt',
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }

      return 'Mình chưa thể trả lời lúc này. Lỗi: ${response.statusCode}';
    } catch (_) {
      return 'Đã xảy ra lỗi kết nối hệ thống.';
    }
  }

  Future<void> _send(String text) async {
    final content = text.trim();
    final session = _currentSession;

    if (content.isEmpty || session == null || _isLoading) return;

    if (session.serverId == null) {
      final serverId = await _createChatSessionApi();

      if (serverId == null) {
        return;
      }

      session.serverId = serverId;
      await _saveSessions();
    }

    final now = DateTime.now();

    setState(() {
      session.messages.add(
        _Message(text: content, isUser: true, createdAt: now),
      );

      final userMsgCount = session.messages.where((m) => m.isUser).length;
      if (userMsgCount == 1) {
        session.title =
            content.length > 28 ? '${content.substring(0, 28)}...' : content;
      }

      session.updatedAt = now;
      _sortSessions();
      _isLoading = true;
    });

    _ctrl.clear();
    await _saveSessions();

    await _saveChatMessageApi(
      sessionId: session.serverId!,
      content: content,
      sender: 'user',
    );

    _scrollToBottom();

    final reply = await _getGeminiResponse(content);

    if (!mounted) return;

    setState(() {
      session.messages.add(
        _Message(text: reply, isUser: false, createdAt: DateTime.now()),
      );
      session.updatedAt = DateTime.now();
      _sortSessions();
      _isLoading = false;
    });

    await _saveChatMessageApi(
      sessionId: session.serverId!,
      content: reply,
      sender: 'ai',
    );

    await _saveSessions();
    _scrollToBottom();
  }

  void _selectSession(_ChatSession session) {
    setState(() {
      _currentSession = session;
    });

    Navigator.pop(context);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeText(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showSnack(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _C.purple700,
        title: const Text(
          'HealthSync AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingSessions || _currentSession == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text(
                'Cuộc trò chuyện mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _createNewSession();
              },
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Gần đây',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  final isSelected = session.id == _currentSession?.id;

                  return ListTile(
                    leading: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: isSelected ? _C.purple400 : Colors.white70,
                      size: 20,
                    ),
                    title: Text(
                      session.title,
                      style: TextStyle(
                        color: isSelected ? _C.purple400 : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _timeText(session.updatedAt),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => _deleteSession(session.id),
                    ),
                    onTap: () => _selectSession(session),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _currentSession!.messages;

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('HealthSync AI đang suy nghĩ...'),
              ],
            ),
          );
        }

        final msg = messages[index];

        return Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: msg.isUser ? _C.userBubble : _C.aiBubble,
              borderRadius: BorderRadius.circular(20),
              border: msg.isUser ? null : Border.all(color: _C.border),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : _C.textMain,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              onSubmitted: _send,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Hỏi gì về sức khỏe...',
                hintStyle: const TextStyle(color: _C.textHint),
                filled: true,
                fillColor: _C.purple100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(_ctrl.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: _C.purple400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
