import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _C {
  static const bg = Color(0xFFF2FBF6);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFC8EDD8);
  static const mint100 = Color(0xFFD5F5E3);
  static const mint400 = Color(0xFF6BBFA0);
  static const mint700 = Color(0xFF2A7A50);
  static const lavender = Color(0xFFEDE6FB);
  static const lavender4 = Color(0xFF8A4FA8);
  static const peach = Color(0xFFFCE9DF);
  static const peach4 = Color(0xFFD4714A);
  static const amber100 = Color(0xFFFEF3DE);
  static const amber4 = Color(0xFFC07A1A);
  static const red100 = Color(0xFFFFE5E5);
  static const red400 = Color(0xFFE05A5A);

  static const textMain = Color(0xFF2A7A50);
  static const textSub = Color(0xFF6BBFA0);
  static const textHint = Color(0xFFAAD4BE);
}

class _Reminder {
  final int id;
  String emoji;
  String name;
  String desc;
  String time;
  bool done;
  DateTime updatedAt;

  _Reminder({
    required this.id,
    required this.emoji,
    required this.name,
    required this.desc,
    required this.time,
    required this.updatedAt,
    this.done = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'name': name,
      'desc': desc,
      'time': time,
      'done': done,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _Reminder.fromJson(Map<String, dynamic> json) {
    return _Reminder(
      id: json['id'] as int,
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      desc: json['desc'] as String,
      time: json['time'] as String,
      done: json['done'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  static const String _storageKey = 'health_reminders';

  bool _isLoading = true;
  final List<_Reminder> _reminders = [];

  List<_Reminder> get _pending => _sorted(_reminders.where((r) => !r.done));
  List<_Reminder> get _done => _sorted(_reminders.where((r) => r.done));

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      _reminders
        ..clear()
        ..addAll(_defaultReminders());
      await _saveReminders();
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _reminders
        ..clear()
        ..addAll(
          decoded.map((e) => _Reminder.fromJson(e as Map<String, dynamic>)),
        );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  List<_Reminder> _defaultReminders() {
    final now = DateTime.now();

    return [
      _Reminder(
        id: 1,
        emoji: '💊',
        name: 'Uống thuốc huyết áp',
        desc: '1 viên sau ăn sáng',
        time: '08:00',
        done: true,
        updatedAt: now,
      ),
      _Reminder(
        id: 2,
        emoji: '🏃',
        name: 'Tập thể dục',
        desc: '30 phút đi bộ nhẹ',
        time: '18:00',
        updatedAt: now,
      ),
      _Reminder(
        id: 3,
        emoji: '🩺',
        name: 'Đo huyết áp',
        desc: 'Ngồi nghỉ 5 phút trước',
        time: '20:00',
        updatedAt: now,
      ),
      _Reminder(
        id: 4,
        emoji: '💊',
        name: 'Uống vitamin D',
        desc: '1 viên sau ăn trưa',
        time: '13:00',
        updatedAt: now,
      ),
    ];
  }

  List<_Reminder> _sorted(Iterable<_Reminder> source) {
    final list = source.toList();
    list.sort((a, b) => _timeMinutes(a.time).compareTo(_timeMinutes(b.time)));
    return list;
  }

  int _timeMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 99999;

    final h = int.tryParse(parts[0]) ?? 99;
    final m = int.tryParse(parts[1]) ?? 99;

    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _C.mint400,
        foregroundColor: Colors.white,
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm nhắc nhở'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Hôm nay (${_pending.length})'),
                          const SizedBox(height: 10),
                          if (_pending.isEmpty)
                            _buildEmptyState('Không còn nhắc nhở nào chưa xong')
                          else
                            ..._pending.map((r) => _buildReminderCard(r)),
                          if (_done.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSectionTitle(
                                'Đã hoàn thành (${_done.length})'),
                            const SizedBox(height: 10),
                            ..._done.map((r) => _buildReminderCard(r)),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final pending = _pending.length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F9EF), Color(0xFFD5F5E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhắc lịch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _C.mint700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pending == 0
                ? 'Bạn đã hoàn thành các nhắc nhở hôm nay'
                : '$pending nhắc nhở chưa hoàn thành hôm nay',
            style: const TextStyle(fontSize: 12, color: _C.textSub),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryChip(
            Icons.hourglass_bottom_rounded, '${_pending.length}', 'Chưa xong'),
        const SizedBox(width: 8),
        _summaryChip(Icons.check_circle_rounded, '${_done.length}', 'Xong rồi'),
        const SizedBox(width: 8),
        _summaryChip(
            Icons.list_alt_rounded, '${_reminders.length}', 'Tổng cộng'),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: _C.mint700, size: 19),
            const SizedBox(height: 5),
            Text(
              val,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.mint700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: _C.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _C.mint700,
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: _C.textSub,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReminderCard(_Reminder reminder) {
    final style = _styleFor(reminder.emoji);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: reminder.done ? 0.58 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: _C.mint400.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: style.$1,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    reminder.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.textMain,
                        decoration:
                            reminder.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.desc.isEmpty ? 'Không có mô tả' : reminder.desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Cập nhật: ${_dateTimeText(reminder.updatedAt)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _C.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: _C.mint100,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      reminder.time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _C.mint700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _iconButton(
                        icon: Icons.edit_rounded,
                        bg: _C.amber100,
                        color: _C.amber4,
                        onTap: () => _showEditSheet(reminder),
                      ),
                      const SizedBox(width: 7),
                      _iconButton(
                        icon: Icons.delete_rounded,
                        bg: _C.red100,
                        color: _C.red400,
                        onTap: () => _showDeleteDialog(reminder),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () => _toggleDone(reminder),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color:
                                reminder.done ? _C.mint400 : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: reminder.done ? _C.mint400 : _C.textHint,
                              width: 2,
                            ),
                          ),
                          child: reminder.done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color bg,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  (Color, Color) _styleFor(String emoji) {
    switch (emoji) {
      case '🏃':
        return (_C.peach, _C.peach4);
      case '🩺':
        return (_C.lavender, _C.lavender4);
      case '💧':
        return (_C.mint100, _C.mint400);
      case '💊':
        return (_C.amber100, _C.amber4);
      default:
        return (_C.mint100, _C.mint700);
    }
  }

  Future<void> _toggleDone(_Reminder reminder) async {
    setState(() {
      reminder.done = !reminder.done;
      reminder.updatedAt = DateTime.now();
    });

    await _saveReminders();
  }

  Future<void> _showAddSheet() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedEmoji = '🔔';
    TimeOfDay selectedTime = TimeOfDay.now();

    await _showReminderSheet(
      title: 'Thêm nhắc nhở',
      actionText: 'Lưu nhắc nhở',
      actionColor: _C.mint400,
      nameCtrl: nameCtrl,
      descCtrl: descCtrl,
      selectedEmoji: selectedEmoji,
      selectedTime: selectedTime,
      onSave: (emoji, time) async {
        final name = nameCtrl.text.trim();

        if (name.isEmpty) {
          _showMessage('Vui lòng nhập tên nhắc nhở');
          return;
        }

        setState(() {
          _reminders.add(
            _Reminder(
              id: DateTime.now().millisecondsSinceEpoch,
              emoji: emoji,
              name: name,
              desc: descCtrl.text.trim(),
              time: _formatTime(time),
              updatedAt: DateTime.now(),
            ),
          );
        });

        await _saveReminders();

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _showEditSheet(_Reminder reminder) async {
    final nameCtrl = TextEditingController(text: reminder.name);
    final descCtrl = TextEditingController(text: reminder.desc);
    final parsedTime = _parseTime(reminder.time);
    String selectedEmoji = reminder.emoji;
    TimeOfDay selectedTime = parsedTime ?? TimeOfDay.now();

    await _showReminderSheet(
      title: 'Sửa nhắc nhở',
      actionText: 'Cập nhật',
      actionColor: _C.amber4,
      nameCtrl: nameCtrl,
      descCtrl: descCtrl,
      selectedEmoji: selectedEmoji,
      selectedTime: selectedTime,
      onSave: (emoji, time) async {
        final name = nameCtrl.text.trim();

        if (name.isEmpty) {
          _showMessage('Vui lòng nhập tên nhắc nhở');
          return;
        }

        setState(() {
          reminder.emoji = emoji;
          reminder.name = name;
          reminder.desc = descCtrl.text.trim();
          reminder.time = _formatTime(time);
          reminder.updatedAt = DateTime.now();
        });

        await _saveReminders();

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _showReminderSheet({
    required String title,
    required String actionText,
    required Color actionColor,
    required TextEditingController nameCtrl,
    required TextEditingController descCtrl,
    required String selectedEmoji,
    required TimeOfDay selectedTime,
    required Future<void> Function(String emoji, TimeOfDay time) onSave,
  }) async {
    final emojis = ['🔔', '💊', '🏃', '🩺', '💧', '🍎', '😴'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _C.mint700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: emojis.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final emoji = emojis[i];
                            final selected = selectedEmoji == emoji;

                            return GestureDetector(
                              onTap: () {
                                setSheetState(() => selectedEmoji = emoji);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _C.mint100
                                      : const Color(0xFFF6FAF8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? _C.mint400 : _C.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameCtrl,
                        decoration: _inputDecoration('Tên nhắc nhở'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        decoration: _inputDecoration('Mô tả'),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (picked != null) {
                            setSheetState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _C.mint100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _C.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: _C.mint700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(selectedTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _C.mint700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => onSave(selectedEmoji, selectedTime),
                          child: Text(
                            actionText,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog(_Reminder reminder) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa nhắc nhở'),
        content: Text('Bạn có muốn xóa "${reminder.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.red400,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _reminders.removeWhere((r) => r.id == reminder.id);
    });

    await _saveReminders();

    _showMessage('Đã xóa nhắc nhở');
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _C.textHint, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF6FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.mint400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dateTimeText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');

    if (diff == 0) return 'Hôm nay $h:$m';
    if (diff == 1) return 'Hôm qua $h:$m';
    return '${date.day}/${date.month} $h:$m';
  }

  void _showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
