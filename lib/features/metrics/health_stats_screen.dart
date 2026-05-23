import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  static const green400 = Color(0xFF3A9A5C);
}

class HealthStatsScreen extends StatefulWidget {
  const HealthStatsScreen({super.key});
  @override
  State<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends State<HealthStatsScreen> {
  int _selectedPeriod = 7; // 7 or 30 days
  int _selectedChart = 0; // 0=nhip tim, 1=can nang, 2=duong huyet, 3=huyet ap

  // ── Dữ liệu mẫu ──────────────────────────────────────────────
  final Map<String, List<double>> _data7 = {
    'nhiptim': [70, 72, 75, 71, 68, 73, 72],
    'cannang': [58.2, 58.0, 57.8, 58.1, 57.9, 57.7, 58.0],
    'duonghuyet': [95, 98, 92, 96, 94, 97, 95],
    'huyetap': [120, 118, 122, 119, 121, 117, 120],
  };

  final Map<String, List<double>> _data30 = {
    'nhiptim': [
      68,
      70,
      72,
      71,
      73,
      75,
      72,
      70,
      69,
      71,
      74,
      73,
      72,
      70,
      68,
      71,
      73,
      72,
      74,
      75,
      72,
      70,
      71,
      73,
      72,
      68,
      70,
      72,
      71,
      72,
    ],
    'cannang': [
      59,
      58.8,
      58.6,
      58.5,
      58.4,
      58.2,
      58.3,
      58.1,
      58.0,
      57.9,
      57.8,
      57.9,
      58.0,
      57.8,
      57.7,
      57.6,
      57.8,
      57.9,
      58.0,
      57.8,
      57.7,
      57.6,
      57.8,
      57.9,
      58.0,
      57.8,
      57.7,
      57.9,
      58.0,
      58.0,
    ],
    'duonghuyet': [
      96,
      95,
      98,
      94,
      97,
      95,
      93,
      96,
      98,
      95,
      94,
      96,
      97,
      95,
      93,
      96,
      94,
      95,
      98,
      96,
      94,
      95,
      97,
      96,
      94,
      95,
      96,
      94,
      95,
      95,
    ],
    'huyetap': [
      122,
      120,
      118,
      121,
      119,
      120,
      122,
      118,
      120,
      121,
      119,
      120,
      118,
      122,
      120,
      119,
      121,
      120,
      118,
      122,
      120,
      119,
      121,
      120,
      118,
      122,
      120,
      119,
      121,
      120,
    ],
  };

  final _chartLabels = ['Nhip tim', 'Can nang', 'Duong huyet', 'Huyet ap'];
  final _chartKeys = ['nhiptim', 'cannang', 'duonghuyet', 'huyetap'];
  final _chartUnits = ['bpm', 'kg', 'mg/dL', 'mmHg'];
  final _chartColors = [
    Color(0xFFE07FA8),
    Color(0xFF378ADD),
    Color(0xFF3A9A5C),
    Color(0xFF8A4FA8),
  ];
  final _chartIcons = [
    Icons.favorite_rounded,
    Icons.monitor_weight_rounded,
    Icons.bloodtype_rounded,
    Icons.water_drop_rounded,
  ];

  List<double> get _currentData {
    final key = _chartKeys[_selectedChart];
    return _selectedPeriod == 7 ? _data7[key]! : _data30[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildPeriodToggle(),
                    const SizedBox(height: 12),
                    _buildChartSelector(),
                    const SizedBox(height: 12),
                    _buildLineChart(),
                    const SizedBox(height: 16),
                    _buildBarChartSection(),
                    const SizedBox(height: 16),
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

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F4FB), Color(0xFFD8EEF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  'Bieu do thong ke',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _C.blue700,
                  ),
                ),
                Text(
                  'Theo doi xu huong suc khoe',
                  style: TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4 Summary Cards ──────────────────────────────────────────
  Widget _buildSummaryCards() {
    final items = [
      (Icons.favorite_rounded, _chartColors[0], 'Nhip tim', '72 bpm'),
      (Icons.monitor_weight_rounded, _chartColors[1], 'Can nang', '58 kg'),
      (Icons.bloodtype_rounded, _chartColors[2], 'Duong huyet', '95'),
      (Icons.water_drop_rounded, _chartColors[3], 'Huyet ap', '120/80'),
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

  // ── Period Toggle ─────────────────────────────────────────────
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
                      boxShadow: _selectedPeriod == p
                          ? [
                              BoxShadow(
                                color: _C.blue200.withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '$p ngay',
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

  // ── Chart Selector ────────────────────────────────────────────
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

  // ── Line Chart ────────────────────────────────────────────────
  Widget _buildLineChart() {
    final data = _currentData;
    final color = _chartColors[_selectedChart];
    final unit = _chartUnits[_selectedChart];
    final minY = data.reduce((a, b) => a < b ? a : b) - 3;
    final maxY = data.reduce((a, b) => a > b ? a : b) + 3;
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final avg = data.reduce((a, b) => a + b) / data.length;

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
                '${_chartLabels[_selectedChart]} - $_selectedPeriod ngay qua',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: _C.blue100, strokeWidth: 1),
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
                        if (_selectedPeriod == 7) {
                          final days = [
                            'T2',
                            'T3',
                            'T4',
                            'T5',
                            'T6',
                            'T7',
                            'CN',
                          ];
                          if (idx >= 0 && idx < days.length)
                            return Text(
                              days[idx],
                              style: const TextStyle(
                                fontSize: 9,
                                color: _C.textHint,
                              ),
                            );
                        } else {
                          if (idx % 5 == 0)
                            return Text(
                              'N${idx + 1}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: _C.textHint,
                              ),
                            );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
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
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bar Chart (7 ngày hoạt động) ─────────────────────────────
  Widget _buildBarChartSection() {
    final steps = [6200.0, 8100.0, 5400.0, 9200.0, 7300.0, 6800.0, 8500.0];
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

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
              const Icon(
                Icons.directions_walk_rounded,
                color: _C.green400,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Buoc chan 7 ngay qua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF5E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'TB: 7,371',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _C.green400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: 10000,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: _C.blue100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= 0 && i < days.length)
                          return Text(
                            days[i],
                            style: const TextStyle(
                              fontSize: 10,
                              color: _C.textHint,
                            ),
                          );
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000
                            ? '${(v / 1000).toStringAsFixed(0)}k'
                            : v.toInt().toString(),
                        style: const TextStyle(fontSize: 9, color: _C.textHint),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: steps
                    .asMap()
                    .entries
                    .map(
                      (e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            gradient: LinearGradient(
                              colors: e.value >= 8000
                                  ? [
                                      const Color(0xFF6BBF96),
                                      const Color(0xFF3A9A5C),
                                    ]
                                  : [
                                      const Color(0xFFB5D4F4),
                                      const Color(0xFF378ADD),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Table ──────────────────────────────────────────────
  Widget _buildRecentTable() {
    final rows = [
      ['Hom nay', '72 bpm', '120/80', '58.0 kg', '95'],
      ['Hom qua', '70 bpm', '118/78', '58.1 kg', '97'],
      ['2 ngay truoc', '75 bpm', '122/82', '57.9 kg', '92'],
      ['3 ngay truoc', '71 bpm', '119/80', '58.2 kg', '96'],
    ];

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
                'Lich su gan day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: _C.blue100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Ngay',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tim',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'HA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Can',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'DH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map(
            (r) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _C.blue100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      r[0],
                      style: const TextStyle(
                        fontSize: 10,
                        color: _C.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r[1],
                      style: const TextStyle(fontSize: 10, color: _C.textSub),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r[2],
                      style: const TextStyle(fontSize: 10, color: _C.textSub),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r[3],
                      style: const TextStyle(fontSize: 10, color: _C.textSub),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r[4],
                      style: const TextStyle(fontSize: 10, color: _C.textSub),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
