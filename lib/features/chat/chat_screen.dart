import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  _Message({required this.text, required this.isUser});

  Map<String, dynamic> toJson() => {"text": text, "isUser": isUser};

  factory _Message.fromJson(Map<String, dynamic> json) {
    return _Message(text: json["text"], isUser: json["isUser"]);
  }
}

class _ChatSession {
  final String id;
  String title;
  List<_Message> messages;

  _ChatSession({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "messages": messages.map((e) => e.toJson()).toList(),
      };

  factory _ChatSession.fromJson(Map<String, dynamic> json) {
    final msgsJson = json["messages"] as List;
    return _ChatSession(
      id: json["id"],
      title: json["title"],
      messages: msgsJson.map((e) => _Message.fromJson(e)).toList(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _isLoading = false;
  static const String _apiKey = "AIzaSyBQDVsE-8te0Uu_ow9iWZzO4StqyvxqZwY";

  List<_ChatSession> _sessions = [];
  _ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("chat_sessions_v2");

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        _sessions = decoded.map((e) => _ChatSession.fromJson(e)).toList();
        if (_sessions.isNotEmpty) {
          _currentSession = _sessions.first; // Mở cuộc trò chuyện gần nhất
        } else {
          _createNewSession();
        }
      });
    } else {
      _createNewSession(); // Nếu chưa có gì thì tạo cuộc trò chuyện đầu tiên
    }
    _scrollToBottom();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_sessions.map((e) => e.toJson()).toList());
    await prefs.setString("chat_sessions_v2", data);
  }

  void _createNewSession() {
    final newSession = _ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Cuộc trò chuyện mới",
      messages: [
        _Message(
          text:
              "Xin chào 👋\nMình là HealthSync AI.\nBạn cần hỗ trợ gì hôm nay?",
          isUser: false,
        ),
      ],
    );

    setState(() {
      _sessions.insert(0, newSession);
      _currentSession = newSession;
    });
    _saveSessions();
  }

  void _deleteSession(String sessionId) {
    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_sessions.isEmpty) {
        _createNewSession();
      } else if (_currentSession?.id == sessionId) {
        _currentSession = _sessions.first;
      }
    });
    _saveSessions();
  }

  Future<String> _getGeminiResponse(String prompt) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Bạn là HealthSync AI. Hãy trả lời bằng tiếng Việt ngắn gọn, dễ hiểu.\n\nCâu hỏi: $prompt",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Mình chưa thể trả lời lúc này 😢 (Lỗi: ${response.statusCode})";
      }
    } catch (e) {
      return "Đã xảy ra lỗi kết nối hệ thống.";
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _currentSession == null) return;

    final userMsg = _Message(text: text, isUser: true);

    setState(() {
      _currentSession!.messages.add(userMsg);

      int userMsgCount =
          _currentSession!.messages.where((m) => m.isUser).length;
      if (userMsgCount == 1) {
        _currentSession!.title =
            text.length > 25 ? "${text.substring(0, 25)}..." : text;
      }

      _isLoading = true;
    });

    _ctrl.clear();
    _scrollToBottom();
    await _saveSessions();

    final reply = await _getGeminiResponse(text);
    final aiMsg = _Message(text: reply, isUser: false);

    setState(() {
      _currentSession!.messages.add(aiMsg);
      _isLoading = false;
    });

    await _saveSessions();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text(
                  "Cuộc trò chuyện mới",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _createNewSession();
                },
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Gần đây",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.grey, size: 20),
                        onPressed: () =>
                            _deleteSession(session.id), // Nút xóa chat
                      ),
                      onTap: () {
                        setState(() {
                          _currentSession = session; // Chuyển sang chat đã chọn
                        });
                        Navigator.pop(context);
                        _scrollToBottom();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _C.purple700,
        title: const Text(
          "HealthSync AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _currentSession == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _currentSession!.messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading &&
                          index == _currentSession!.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text("HealthSync AI đang suy nghĩ..."),
                            ],
                          ),
                        );
                      }

                      final msg = _currentSession!.messages[index];

                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser ? _C.userBubble : _C.aiBubble,
                            borderRadius: BorderRadius.circular(20),
                            border: msg.isUser
                                ? null
                                : Border.all(color: _C.border),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : _C.textMain,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
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
                          decoration: InputDecoration(
                            hintText: "Hỏi gì về sức khỏe...",
                            hintStyle: const TextStyle(color: _C.textHint),
                            filled: true,
                            fillColor: _C.purple100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
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
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
