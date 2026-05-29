import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

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
}

class HealthMetricEntry {
  final String key;
  final double value;
  final double? secondValue;
  final String unit;
  final DateTime measuredAt;

  HealthMetricEntry({
    required this.key,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.secondValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'secondValue': secondValue,
      'unit': unit,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  factory HealthMetricEntry.fromJson(Map<String, dynamic> json) {
    return HealthMetricEntry(
      key: json['key'],
      value: (json['value'] as num).toDouble(),
      secondValue: json['secondValue'] == null
          ? null
          : (json['secondValue'] as num).toDouble(),
      unit: json['unit'],
      measuredAt: DateTime.parse(json['measuredAt']),
    );
  }
}

class HealthStatsScreen extends StatefulWidget {
  const HealthStatsScreen({super.key});

  @override
  State<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends State<HealthStatsScreen> {
  static const String _storageKey = 'health_metric_entries';

  int _selectedPeriod = 7;
  int _selectedChart = 0;
  bool _isSyncing = false;
  bool _isLoading = true;

  final List<HealthMetricEntry> _entries = [];

  final _chartLabels = ['Nhịp tim', 'Cân nặng', 'Đường huyết', 'Huyết áp'];
  final _chartKeys = ['nhiptim', 'cannang', 'duonghuyet', 'huyetap'];
  final _chartUnits = ['bpm', 'kg', 'mg/dL', 'mmHg'];
  final _chartColors = [
    const Color(0xFFE07FA8),
    const Color(0xFF378ADD),
    const Color(0xFF3A9A5C),
    const Color(0xFF8A4FA8),
  ];
  final _chartIcons = [
    Icons.favorite_rounded,
    Icons.monitor_weight_rounded,
    Icons.bloodtype_rounded,
    Icons.water_drop_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          decoded.map(
            (e) => HealthMetricEntry.fromJson(e as Map<String, dynamic>),
          ),
        );
    }

    _sortEntries();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  void _sortEntries() {
    _entries.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  HealthMetricEntry? _latestEntry(String key) {
    final matches = _entries.where((e) => e.key == key).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return matches.first;
  }

  List<double?> _seriesFor(String key) {
    final now = DateTime.now();
    final result = List<double?>.filled(_selectedPeriod, null);

    for (int i = 0; i < _selectedPeriod; i++) {
      final date = now.subtract(Duration(days: _selectedPeriod - 1 - i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayEntries = _entries.where((e) {
        return e.key == key &&
            !e.measuredAt.isBefore(dayStart) &&
            e.measuredAt.isBefore(dayEnd);
      }).toList();

      if (dayEntries.isNotEmpty) {
        final avg = dayEntries.map((e) => e.value).reduce((a, b) => a + b) /
            dayEntries.length;
        result[i] = avg;
      }
    }

    return result;
  }

  List<double?> get _currentSeries {
    return _seriesFor(_chartKeys[_selectedChart]);
  }

  double? get _average {
    final values = _currentSeries.whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String _formatValue(HealthMetricEntry? entry) {
    if (entry == null) return 'Chưa có';

    if (entry.key == 'huyetap') {
      final sys = entry.value.toInt();
      final dia = entry.secondValue?.toInt();
      return dia == null ? '$sys mmHg' : '$sys/$dia';
    }

    final hasDecimal = entry.key == 'cannang';
    final value = hasDecimal
        ? entry.value.toStringAsFixed(1)
        : entry.value.toStringAsFixed(0);

    return '$value ${entry.unit}';
  }

  String _dayLabel(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = todayOnly.difference(dateOnly).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _C.blue400,
        foregroundColor: Colors.white,
        onPressed: _showAddMetricSheet,
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 16),
                          _buildPeriodToggle(),
                          const SizedBox(height: 12),
                          _buildChartSelector(),
                          const SizedBox(height: 16),
                          _buildLineChart(),
                          const SizedBox(height: 20),
                          _buildRecentTable(),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _C.blue200),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _C.blue700,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biểu đồ thống kê',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _C.blue700,
                  ),
                ),
                Text(
                  'Theo dõi xu hướng sức khỏe từ dữ liệu bạn nhập',
                  style: TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
          _buildSyncButton(),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return GestureDetector(
      onTap: _syncHealthMetrics,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _C.blue100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isSyncing ? Icons.hourglass_bottom : Icons.sync_rounded,
              size: 16,
              color: _C.blue700,
            ),
            const SizedBox(width: 4),
            Text(
              _isSyncing ? 'Đang sync...' : 'Đồng bộ',
              style: const TextStyle(fontSize: 12, color: _C.blue700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncHealthMetrics() async {
    if (_isSyncing) return;

    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có dữ liệu để đồng bộ')),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
            'https://healthsync-ai-y60b.onrender.com/api/health-metrics/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'metrics': _entries.map((e) {
            final index = _chartKeys.indexOf(e.key);
            return {
              'metricType': index >= 0 ? _chartLabels[index] : e.key,
              'value': e.value,
              'secondValue': e.secondValue,
              'unit': e.unit,
              'measuredAt': e.measuredAt.toIso8601String(),
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đồng bộ dữ liệu thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đồng bộ: ${response.statusCode}')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể kết nối với server')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Widget _buildSummaryCards() {
    final items = [
      (
        Icons.favorite_rounded,
        _chartColors[0],
        'Nhịp tim',
        _formatValue(_latestEntry('nhiptim'))
      ),
      (
        Icons.monitor_weight_rounded,
        _chartColors[1],
        'Cân nặng',
        _formatValue(_latestEntry('cannang'))
      ),
      (
        Icons.bloodtype_rounded,
        _chartColors[2],
        'Đường huyết',
        _formatValue(_latestEntry('duonghuyet'))
      ),
      (
        Icons.water_drop_rounded,
        _chartColors[3],
        'Huyết áp',
        _formatValue(_latestEntry('huyetap'))
      ),
    ];

    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: e == items.last ? 0 : 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border),
                  ),
                  child: Column(
                    children: [
                      Icon(e.$1, color: e.$2, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        e.$4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: e.$2,
                        ),
                      ),
                      Text(
                        e.$3,
                        style: const TextStyle(
                          fontSize: 8,
                          color: _C.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _C.blue100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [7, 30]
            .map(
              (p) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == p
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$p ngày',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedPeriod == p ? _C.blue700 : _C.textHint,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChartSelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chartLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedChart == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedChart = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _chartColors[i] : _C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _chartColors[i] : _C.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _chartIcons[i],
                    size: 14,
                    color: selected ? Colors.white : _C.textSub,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _chartLabels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _C.textSub,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLineChart() {
    final series = _currentSeries;
    final values = series.whereType<double>().toList();
    final color = _chartColors[_selectedChart];
    final unit = _chartUnits[_selectedChart];
    final avg = _average;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_chartIcons[_selectedChart], color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_chartLabels[_selectedChart]} - $_selectedPeriod ngày qua',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
              const Spacer(),
              if (avg != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TB: ${avg.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (values.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 180,
              child: LineChart(_lineChartData(series, color)),
            ),
        ],
      ),
    );
  }

  LineChartData _lineChartData(List<double?> series, Color color) {
    final values = series.whereType<double>().toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final minY = minValue == maxValue ? minValue - 5 : minValue - 3;
    final maxY = minValue == maxValue ? maxValue + 5 : maxValue + 3;

    final spots = <FlSpot>[];
    for (int i = 0; i < series.length; i++) {
      final value = series[i];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    return LineChartData(
      minX: 0,
      maxX: (_selectedPeriod - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: _C.blue100,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 9, color: _C.textHint),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _selectedPeriod == 7 ? 1 : 5,
            getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < 0 || idx >= _selectedPeriod) {
                return const SizedBox.shrink();
              }

              if (_selectedPeriod == 7) {
                final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                return Text(
                  labels[idx % 7],
                  style: const TextStyle(fontSize: 9, color: _C.textHint),
                );
              }

              return Text(
                'N${idx + 1}',
                style: const TextStyle(fontSize: 9, color: _C.textHint),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: spots.length > 2,
          color: color,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _C.blue100.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Chưa có dữ liệu.\nBấm "Thêm chỉ số" để bắt đầu theo dõi.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: _C.textSub,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentTable() {
    final rows = _buildRecentRows();

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: _C.blue400, size: 18),
              SizedBox(width: 8),
              Text(
                'Lịch sử gần đây',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: _C.blue100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderCell('Ngày')),
                Expanded(flex: 2, child: _HeaderCell('Tim')),
                Expanded(flex: 2, child: _HeaderCell('HA')),
                Expanded(flex: 2, child: _HeaderCell('Cân')),
                Expanded(flex: 2, child: _HeaderCell('DH')),
              ],
            ),
          ),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Chưa có lịch sử đo',
                  style: TextStyle(
                    fontSize: 12,
                    color: _C.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ...rows.map(
              (r) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: _C.blue100)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _BodyCell(r[0], isMain: true)),
                    Expanded(flex: 2, child: _BodyCell(r[1])),
                    Expanded(flex: 2, child: _BodyCell(r[2])),
                    Expanded(flex: 2, child: _BodyCell(r[3])),
                    Expanded(flex: 2, child: _BodyCell(r[4])),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<List<String>> _buildRecentRows() {
    final days = <DateTime>{};

    for (final entry in _entries) {
      days.add(DateTime(
        entry.measuredAt.year,
        entry.measuredAt.month,
        entry.measuredAt.day,
      ));
    }

    final sortedDays = days.toList()..sort((a, b) => b.compareTo(a));

    return sortedDays.take(5).map((day) {
      HealthMetricEntry? findLatest(String key) {
        final matches = _entries.where((e) {
          final d =
              DateTime(e.measuredAt.year, e.measuredAt.month, e.measuredAt.day);
          return d == day && e.key == key;
        }).toList();

        if (matches.isEmpty) return null;
        matches.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
        return matches.first;
      }

      return [
        _dayLabel(day),
        _formatValue(findLatest('nhiptim')),
        _formatValue(findLatest('huyetap')),
        _formatValue(findLatest('cannang')),
        _formatValue(findLatest('duonghuyet')),
      ];
    }).toList();
  }

  Future<void> _showAddMetricSheet() async {
    String selectedKey = _chartKeys[_selectedChart];
    final valueController = TextEditingController();
    final secondValueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isBloodPressure = selectedKey == 'huyetap';
            final selectedIndex = _chartKeys.indexOf(selectedKey);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
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
                    const Text(
                      'Thêm chỉ số sức khỏe',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedKey,
                      decoration: _inputDecoration('Loại chỉ số'),
                      items: List.generate(_chartKeys.length, (i) {
                        return DropdownMenuItem(
                          value: _chartKeys[i],
                          child: Text(_chartLabels[i]),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;
                        valueController.clear();
                        secondValueController.clear();
                        setSheetState(() => selectedKey = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isBloodPressure)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: valueController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Tâm thu'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: secondValueController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Tâm trương'),
                            ),
                          ),
                        ],
                      )
                    else
                      TextField(
                        controller: valueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Giá trị (${_chartUnits[selectedIndex]})',
                        ),
                      ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              DateTime.now().hour,
                              DateTime.now().minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _C.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _C.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: _C.blue700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ngày đo: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _C.textMain,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _chartColors[selectedIndex],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final value = double.tryParse(
                            valueController.text.trim().replaceAll(',', '.'),
                          );

                          final secondValue = double.tryParse(
                            secondValueController.text
                                .trim()
                                .replaceAll(',', '.'),
                          );

                          if (value == null ||
                              (isBloodPressure && secondValue == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập số hợp lệ'),
                              ),
                            );
                            return;
                          }

                          _entries.add(
                            HealthMetricEntry(
                              key: selectedKey,
                              value: value,
                              secondValue: isBloodPressure ? secondValue : null,
                              unit: _chartUnits[selectedIndex],
                              measuredAt: selectedDate,
                            ),
                          );

                          _sortEntries();
                          await _saveEntries();

                          if (mounted) {
                            setState(() {});
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: const Text(
                          'Lưu chỉ số',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _C.textMain,
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final bool isMain;

  const _BodyCell(this.text, {this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10,
        color: isMain ? _C.textMain : _C.textSub,
        fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
