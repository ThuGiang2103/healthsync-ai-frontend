import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'health_stats_screen.dart';

class _C {
  static const bg = Color(0xFFF0F8FF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFDDF0FA);

  static const blue100 = Color(0xFFDDF0FA);
  static const blue200 = Color(0xFFB5D4F4);
  static const blue400 = Color(0xFF378ADD);
  static const blue700 = Color(0xFF2D6FA8);

  static const textMain = Color(0xFF2D6FA8);
  static const textSub = Color(0xFF7AB2D4);
  static const textHint = Color(0xFFAACCE4);

  static const pink100 = Color(0xFFFCE4EE);
  static const pink400 = Color(0xFFE07FA8);

  static const green100 = Color(0xFFDFF5E8);
  static const green400 = Color(0xFF3A9A5C);

  static const amber100 = Color(0xFFFEF3DE);
  static const amber400 = Color(0xFFC07A1A);

  static const red100 = Color(0xFFFFE5E5);
  static const red400 = Color(0xFFE84D4D);
}

class _Metric {
  final int id;
  final String type;
  final String name;
  final String value;
  final String unit;
  final DateTime updatedAt;

  const _Metric({
    required this.id,
    required this.type,
    required this.name,
    required this.value,
    required this.unit,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'value': value,
      'unit': unit,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _Metric.fromJson(Map<String, dynamic> json) {
    return _Metric(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  _Metric copyWith({
    int? id,
    String? type,
    String? name,
    String? value,
    String? unit,
    DateTime? updatedAt,
  }) {
    return _Metric(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class _MetricStyle {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _MetricStyle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class _MetricStatus {
  final String label;
  final Color bg;
  final Color color;
  final bool good;

  const _MetricStatus({
    required this.label,
    required this.bg,
    required this.color,
    required this.good,
  });
}

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  static const String _metricsStorageKey = 'health_metrics_cards';
  static const String _statsStorageKey = 'health_metric_entries';

  bool _isLoading = true;
  final List<_Metric> _metrics = [];

  final Map<String, String> _typeNames = const {
    'nhiptim': 'Nhịp tim',
    'huyetap': 'Huyết áp',
    'cannang': 'Cân nặng',
    'duonghuyet': 'Đường huyết',
    'custom': 'Chỉ số khác',
  };

  final Map<String, String> _typeUnits = const {
    'nhiptim': 'bpm',
    'huyetap': 'mmHg',
    'cannang': 'kg',
    'duonghuyet': 'mg/dL',
    'custom': '',
  };

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metricsStorageKey);

    if (raw == null || raw.isEmpty) {
      _metrics
        ..clear()
        ..addAll(_defaultMetrics());
      await _saveMetrics();
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _metrics
        ..clear()
        ..addAll(
          decoded.map((e) => _Metric.fromJson(e as Map<String, dynamic>)),
        );
    }

    _sortMetrics();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_metrics.map((e) => e.toJson()).toList());
    await prefs.setString(_metricsStorageKey, raw);
  }

  void _sortMetrics() {
    const order = ['nhiptim', 'huyetap', 'cannang', 'duonghuyet', 'custom'];
    _metrics.sort((a, b) {
      final ai = order.indexOf(a.type);
      final bi = order.indexOf(b.type);
      return ai.compareTo(bi);
    });
  }

  List<_Metric> _defaultMetrics() {
    final now = DateTime.now();

    return [
      _Metric(
        id: 1,
        type: 'nhiptim',
        name: 'Nhịp tim',
        value: '',
        unit: 'bpm',
        updatedAt: now,
      ),
      _Metric(
        id: 2,
        type: 'huyetap',
        name: 'Huyết áp',
        value: '',
        unit: 'mmHg',
        updatedAt: now,
      ),
      _Metric(
        id: 3,
        type: 'cannang',
        name: 'Cân nặng',
        value: '',
        unit: 'kg',
        updatedAt: now,
      ),
      _Metric(
        id: 4,
        type: 'duonghuyet',
        name: 'Đường huyết',
        value: '',
        unit: 'mg/dL',
        updatedAt: now,
      ),
    ];
  }

  _MetricStyle _styleFor(String type) {
    switch (type) {
      case 'nhiptim':
        return const _MetricStyle(
          icon: Icons.favorite_rounded,
          iconBg: _C.pink100,
          iconColor: _C.pink400,
        );
      case 'huyetap':
        return const _MetricStyle(
          icon: Icons.water_drop_rounded,
          iconBg: _C.blue100,
          iconColor: _C.blue400,
        );
      case 'cannang':
        return const _MetricStyle(
          icon: Icons.monitor_weight_rounded,
          iconBg: _C.amber100,
          iconColor: _C.amber400,
        );
      case 'duonghuyet':
        return const _MetricStyle(
          icon: Icons.bloodtype_rounded,
          iconBg: _C.green100,
          iconColor: _C.green400,
        );
      default:
        return const _MetricStyle(
          icon: Icons.add_chart_rounded,
          iconBg: _C.blue100,
          iconColor: _C.blue700,
        );
    }
  }

  _MetricStatus _statusFor(_Metric metric) {
    if (metric.value.trim().isEmpty) {
      return const _MetricStatus(
        label: 'Chưa nhập',
        bg: _C.blue100,
        color: _C.textSub,
        good: false,
      );
    }

    final firstValue = _extractFirstNumber(metric.value);

    if (metric.type == 'nhiptim') {
      final good = firstValue != null && firstValue >= 60 && firstValue <= 100;
      return good ? _goodStatus() : _warningStatus();
    }

    if (metric.type == 'duonghuyet') {
      final good = firstValue != null && firstValue >= 70 && firstValue <= 140;
      return good ? _goodStatus() : _warningStatus();
    }

    if (metric.type == 'huyetap') {
      final parts = metric.value.split('/');
      final sys = parts.isNotEmpty ? double.tryParse(parts[0].trim()) : null;
      final dia = parts.length > 1 ? double.tryParse(parts[1].trim()) : null;
      final good = sys != null &&
          dia != null &&
          sys >= 90 &&
          sys <= 120 &&
          dia >= 60 &&
          dia <= 80;
      return good ? _normalStatus() : _warningStatus();
    }

    return const _MetricStatus(
      label: 'Đã cập nhật',
      bg: _C.blue100,
      color: _C.blue700,
      good: true,
    );
  }

  _MetricStatus _goodStatus() {
    return const _MetricStatus(
      label: 'Tốt',
      bg: _C.green100,
      color: _C.green400,
      good: true,
    );
  }

  _MetricStatus _normalStatus() {
    return const _MetricStatus(
      label: 'Bình thường',
      bg: _C.green100,
      color: _C.green400,
      good: true,
    );
  }

  _MetricStatus _warningStatus() {
    return const _MetricStatus(
      label: 'Cần chú ý',
      bg: _C.amber100,
      color: _C.amber400,
      good: false,
    );
  }

  double? _extractFirstNumber(String value) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(value.replaceAll(',', '.'));
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  int get _goodCount {
    return _metrics
        .where((m) => _statusFor(m).good && m.value.trim().isNotEmpty)
        .length;
  }

  int get _warningCount {
    return _metrics.where((m) {
      final status = _statusFor(m);
      return !status.good && m.value.trim().isNotEmpty;
    }).length;
  }

  DateTime? get _latestUpdatedAt {
    final filled = _metrics.where((m) => m.value.trim().isNotEmpty).toList();
    if (filled.isEmpty) return null;

    filled.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filled.first.updatedAt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _C.blue400,
        foregroundColor: Colors.white,
        onPressed: () => _showMetricSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm chỉ số'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(),
                          const SizedBox(height: 14),
                          _buildChartBanner(context),
                          const SizedBox(height: 18),
                          _buildSectionHeader(),
                          const SizedBox(height: 10),
                          ..._metrics.map(_buildMetricCard),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F4FB), Color(0xFFD8EEF9)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chỉ số sức khỏe',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _C.blue700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Theo dõi các chỉ số bạn tự cập nhật',
                  style: TextStyle(fontSize: 12, color: _C.textSub),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthStatsScreen()),
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.blue200),
                boxShadow: [
                  BoxShadow(
                    color: _C.blue400.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: _C.blue400,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryChip(
          Icons.check_circle_rounded,
          _C.green100,
          _C.green400,
          _goodCount.toString(),
          'Chỉ số tốt',
        ),
        const SizedBox(width: 8),
        _summaryChip(
          Icons.warning_rounded,
          _C.amber100,
          _C.amber400,
          _warningCount.toString(),
          'Cần chú ý',
        ),
        const SizedBox(width: 8),
        _summaryChip(
          Icons.calendar_today_rounded,
          _C.blue100,
          _C.blue400,
          _latestUpdatedAt == null ? '--' : _dayText(_latestUpdatedAt!),
          'Lần đo gần nhất',
        ),
      ],
    );
  }

  Widget _summaryChip(
    IconData icon,
    Color bg,
    Color color,
    String val,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _C.blue700,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                color: _C.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HealthStatsScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF378ADD), Color(0xFF2D6FA8)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _C.blue400.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Xem biểu đồ thống kê',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Chỉ số của bạn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _C.blue700,
            ),
          ),
        ),
        Text(
          '${_metrics.length} mục',
          style: const TextStyle(
            fontSize: 11,
            color: _C.textSub,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(_Metric metric) {
    final style = _styleFor(metric.type);
    final status = _statusFor(metric);
    final hasValue = metric.value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: _C.blue400.withValues(alpha: 0.04),
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
                color: style.iconBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(style.icon, color: style.iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasValue)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: metric.value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _C.blue700,
                            ),
                          ),
                          TextSpan(
                            text: metric.unit.isEmpty ? '' : ' ${metric.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'Chưa có dữ liệu',
                      style: TextStyle(
                        fontSize: 13,
                        color: _C.textHint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Cập nhật: ${hasValue ? _dateTimeText(metric.updatedAt) : '--'}',
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: status.color,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _iconAction(
                      icon: Icons.edit_rounded,
                      bg: _C.blue100,
                      color: _C.blue700,
                      onTap: () => _showMetricSheet(metric: metric),
                    ),
                    const SizedBox(width: 7),
                    _iconAction(
                      icon: Icons.delete_rounded,
                      bg: _C.red100,
                      color: _C.red400,
                      onTap: () => _deleteMetric(metric),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction({
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

  Future<void> _showMetricSheet({_Metric? metric}) async {
    String selectedType = metric?.type ?? 'nhiptim';
    final nameController = TextEditingController(
      text: metric?.name ?? _typeNames[selectedType] ?? '',
    );
    final valueController = TextEditingController(text: metric?.value ?? '');
    final unitController = TextEditingController(
      text: metric?.unit ?? _typeUnits[selectedType] ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isCustom = selectedType == 'custom';
            final style = _styleFor(selectedType);

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
                          color: _C.blue200,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: style.iconBg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(style.icon, color: style.iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              metric == null
                                  ? 'Thêm chỉ số'
                                  : 'Cập nhật chỉ số',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _C.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: _inputDecoration('Loại chỉ số'),
                        items: _typeNames.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedType = value;
                            if (value != 'custom') {
                              nameController.text = _typeNames[value] ?? '';
                              unitController.text = _typeUnits[value] ?? '';
                            } else {
                              nameController.clear();
                              unitController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        enabled: isCustom,
                        decoration: _inputDecoration('Tên chỉ số'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: valueController,
                        keyboardType: TextInputType.text,
                        decoration: _inputDecoration(
                          selectedType == 'huyetap'
                              ? 'Giá trị, ví dụ 120/80'
                              : 'Giá trị',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: unitController,
                        enabled: isCustom,
                        decoration: _inputDecoration('Đơn vị'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.blue400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final value = valueController.text.trim();
                            final unit = unitController.text.trim();

                            if (name.isEmpty || value.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập đủ thông tin'),
                                ),
                              );
                              return;
                            }

                            if (!_isValidValue(selectedType, value)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    selectedType == 'huyetap'
                                        ? 'Huyết áp nhập dạng 120/80'
                                        : 'Giá trị cần là số hợp lệ',
                                  ),
                                ),
                              );
                              return;
                            }

                            final now = DateTime.now();

                            if (metric == null) {
                              final existingIndex = _metrics.indexWhere(
                                (m) =>
                                    m.type == selectedType &&
                                    selectedType != 'custom',
                              );

                              final newMetric = _Metric(
                                id: DateTime.now().millisecondsSinceEpoch,
                                type: selectedType,
                                name: name,
                                value: value,
                                unit: unit,
                                updatedAt: now,
                              );

                              if (existingIndex >= 0) {
                                _metrics[existingIndex] = newMetric.copyWith(
                                  id: _metrics[existingIndex].id,
                                );
                              } else {
                                _metrics.add(newMetric);
                              }
                            } else {
                              final index =
                                  _metrics.indexWhere((m) => m.id == metric.id);
                              if (index >= 0) {
                                _metrics[index] = metric.copyWith(
                                  type: selectedType,
                                  name: name,
                                  value: value,
                                  unit: unit,
                                  updatedAt: now,
                                );
                              }
                            }

                            _sortMetrics();
                            await _saveMetrics();
                            await _appendStatsEntry(
                                selectedType, value, unit, now);

                            if (mounted) {
                              setState(() {});
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: const Text(
                            'Lưu chỉ số',
                            style: TextStyle(fontWeight: FontWeight.w900),
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

  bool _isValidValue(String type, String value) {
    if (type == 'custom') return true;

    if (type == 'huyetap') {
      final parts = value.split('/');
      if (parts.length != 2) return false;

      final sys = double.tryParse(parts[0].trim());
      final dia = double.tryParse(parts[1].trim());

      return sys != null && dia != null;
    }

    return double.tryParse(value.replaceAll(',', '.')) != null;
  }

  Future<void> _appendStatsEntry(
    String type,
    String value,
    String unit,
    DateTime measuredAt,
  ) async {
    if (!['nhiptim', 'cannang', 'duonghuyet', 'huyetap'].contains(type)) {
      return;
    }

    double? firstValue;
    double? secondValue;

    if (type == 'huyetap') {
      final parts = value.split('/');
      firstValue = double.tryParse(parts[0].trim());
      secondValue = parts.length > 1 ? double.tryParse(parts[1].trim()) : null;
    } else {
      firstValue = double.tryParse(value.replaceAll(',', '.'));
    }

    if (firstValue == null) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsStorageKey);
    final list = raw == null || raw.isEmpty
        ? <dynamic>[]
        : jsonDecode(raw) as List<dynamic>;

    list.add({
      'key': type,
      'value': firstValue,
      'secondValue': secondValue,
      'unit': unit,
      'measuredAt': measuredAt.toIso8601String(),
    });

    await prefs.setString(_statsStorageKey, jsonEncode(list));
  }

  Future<void> _deleteMetric(_Metric metric) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa chỉ số'),
        content: Text('Bạn có chắc muốn xóa ${metric.name}?'),
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
      _metrics.removeWhere((m) => m.id == metric.id);
    });

    await _saveMetrics();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa chỉ số')),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _C.textSub),
      filled: true,
      fillColor: _C.bg,
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
        borderSide: const BorderSide(color: _C.blue400),
      ),
    );
  }

  String _dayText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${date.day}/${date.month}';
  }

  String _dateTimeText(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${_dayText(date)} $h:$m';
  }
}
