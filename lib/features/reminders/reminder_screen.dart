import 'package:flutter/material.dart';

// ─── Màu pastel xanh mint ─────────────────────────────────────────
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

// ─── Model ────────────────────────────────────────────────────────
class _Reminder {
  final String emoji;
  String name;
  String desc;
  String time;
  final Color iconBg;
  final Color iconColor;
  bool done;

  _Reminder({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.time,
    required this.iconBg,
    required this.iconColor,
    this.done = false,
  });
}

// ─── Screen ───────────────────────────────────────────────────────
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<_Reminder> _reminders = [
    _Reminder(
      emoji: '💊',
      name: 'Uống thuốc huyết áp',
      desc: '1 viên sau ăn sáng',
      time: '08:00',
      iconBg: _C.mint100,
      iconColor: _C.mint700,
    ),
    _Reminder(
      emoji: '🏃',
      name: 'Tập thể dục',
      desc: '30 phút đi bộ nhẹ',
      time: '18:00',
      iconBg: _C.peach,
      iconColor: _C.peach4,
    ),
    _Reminder(
      emoji: '🩺',
      name: 'Đo huyết áp',
      desc: 'Ngồi nghỉ 5 phút trước',
      time: '20:00',
      iconBg: _C.lavender,
      iconColor: _C.lavender4,
    ),
    _Reminder(
      emoji: '💧',
      name: 'Uống nước',
      desc: 'Mục tiêu 2L mỗi ngày',
      time: 'Cả ngày',
      iconBg: _C.mint100,
      iconColor: _C.mint400,
      done: true,
    ),
    _Reminder(
      emoji: '💊',
      name: 'Uống vitamin D',
      desc: '1 viên sau ăn trưa',
      time: '13:00',
      iconBg: _C.amber100,
      iconColor: _C.amber4,
    ),
  ];

  List<_Reminder> get _pending => _reminders.where((r) => !r.done).toList();
  List<_Reminder> get _done => _reminders.where((r) => r.done).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(),
                    const SizedBox(height: 16),

                    _buildSectionTitle('⏰  Hôm nay (${_pending.length})'),
                    const SizedBox(height: 10),

                    ..._pending.map((r) => _buildReminderCard(r)),

                    if (_done.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('✅  Đã hoàn thành (${_done.length})'),
                      const SizedBox(height: 10),
                      ..._done.map((r) => _buildReminderCard(r)),
                    ],

                    const SizedBox(height: 12),
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
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
              fontWeight: FontWeight.w700,
              color: _C.mint700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$pending nhắc nhở chưa hoàn thành hôm nay',
            style: const TextStyle(fontSize: 12, color: _C.textSub),
          ),
        ],
      ),
    );
  }

  // ── Summary ────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryChip('⏳', '${_pending.length}', 'Chưa xong'),
        const SizedBox(width: 8),
        _summaryChip('✅', '${_done.length}', 'Xong rồi'),
        const SizedBox(width: 8),
        _summaryChip('📋', '${_reminders.length}', 'Tổng cộng'),
      ],
    );
  }

  Widget _summaryChip(String emoji, String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              val,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.mint700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: _C.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────
  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _C.mint700,
      ),
    ),
  );

  // ── Card ───────────────────────────────────────────────────────
  Widget _buildReminderCard(_Reminder r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: r.done ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: r.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(r.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textMain,
                        decoration: r.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      r.desc,
                      style: const TextStyle(fontSize: 11, color: _C.textSub),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _C.mint100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.mint700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Edit
                      GestureDetector(
                        onTap: () => _showEditSheet(r),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _C.amber100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: _C.amber4,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Delete
                      GestureDetector(
                        onTap: () => _showDeleteDialog(r),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _C.red100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            size: 16,
                            color: _C.red400,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Done
                      GestureDetector(
                        onTap: () => setState(() => r.done = !r.done),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: r.done ? _C.mint400 : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: r.done ? _C.mint400 : _C.textHint,
                              width: 2,
                            ),
                          ),
                          child: r.done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
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

  // ── Add button ────────────────────────────────────────────────
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showAddSheet(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.mint100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.mint400, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: _C.mint700, size: 20),
            SizedBox(width: 8),
            Text(
              'Thêm nhắc nhở mới',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.mint700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add ───────────────────────────────────────────────────────
  void _showAddSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '➕ Thêm nhắc nhở',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _C.mint700,
                ),
              ),

              const SizedBox(height: 16),

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
                  final t = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );

                  if (t != null) {
                    setSheetState(() => selectedTime = t);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.mint100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '⏰ ${selectedTime.format(context)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _C.mint700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  if (nameCtrl.text.isNotEmpty) {
                    setState(() {
                      _reminders.insert(
                        0,
                        _Reminder(
                          emoji: '🔔',
                          name: nameCtrl.text,
                          desc: descCtrl.text,
                          time: selectedTime.format(context),
                          iconBg: _C.mint100,
                          iconColor: _C.mint700,
                        ),
                      );
                    });
                  }

                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.mint400,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit ──────────────────────────────────────────────────────
  void _showEditSheet(_Reminder r) {
    final nameCtrl = TextEditingController(text: r.name);
    final descCtrl = TextEditingController(text: r.desc);

    TimeOfDay selectedTime = TimeOfDay(
      hour: int.tryParse(r.time.split(':')[0]) ?? 8,
      minute: int.tryParse(r.time.split(':')[1]) ?? 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✏️ Sửa nhắc nhở',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _C.mint700,
                ),
              ),

              const SizedBox(height: 16),

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
                  final t = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );

                  if (t != null) {
                    setSheetState(() => selectedTime = t);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.mint100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '⏰ ${selectedTime.format(context)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _C.mint700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    r.name = nameCtrl.text;
                    r.desc = descCtrl.text;
                    r.time = selectedTime.format(context);
                  });

                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.amber4,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Cập nhật',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────
  void _showDeleteDialog(_Reminder r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa nhắc nhở'),
        content: Text('Bạn có muốn xóa "${r.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.remove(r);
              });

              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Input decoration ──────────────────────────────────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _C.textHint, fontSize: 13),
      filled: true,
      fillColor: _C.mint100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
