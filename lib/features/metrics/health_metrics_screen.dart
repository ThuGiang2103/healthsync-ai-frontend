import 'package:flutter/material.dart';
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

  static const green100 = Color(0xFFDFF5E8);
  static const green400 = Color(0xFF3A9A5C);

  static const amber100 = Color(0xFFFEF3DE);
  static const amber400 = Color(0xFFC07A1A);
}

class _Metric {
  final int id;
  final IconData icon;
  final String name;
  final String value;
  final String unit;
  final String tag;

  final Color tagBg;
  final Color tagText;

  final Color iconBg;
  final Color iconColor;

  const _Metric({
    required this.id,
    required this.icon,
    required this.name,
    required this.value,
    required this.unit,
    required this.tag,
    required this.tagBg,
    required this.tagText,
    required this.iconBg,
    required this.iconColor,
  });
}

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  final List<_Metric> _metrics = [
    _Metric(
      id: 1,
      icon: Icons.favorite_rounded,
      name: 'Nhip tim',
      value: '72',
      unit: 'bpm',
      tag: 'Tot',
      tagBg: _C.green100,
      tagText: _C.green400,
      iconBg: _C.pink100,
      iconColor: Color(0xFFE07FA8),
    ),

    _Metric(
      id: 2,
      icon: Icons.water_drop_rounded,
      name: 'Huyet ap',
      value: '120/80',
      unit: 'mmHg',
      tag: 'Binh thuong',
      tagBg: _C.blue100,
      tagText: _C.blue700,
      iconBg: _C.blue100,
      iconColor: _C.blue400,
    ),

    _Metric(
      id: 3,
      icon: Icons.monitor_weight_rounded,
      name: 'Can nang',
      value: '58',
      unit: 'kg',
      tag: 'On dinh',
      tagBg: _C.green100,
      tagText: _C.green400,
      iconBg: _C.amber100,
      iconColor: _C.amber400,
    ),

    _Metric(
      id: 4,
      icon: Icons.bloodtype_rounded,
      name: 'Duong huyet',
      value: '95',
      unit: 'mg/dL',
      tag: 'Tot',
      tagBg: _C.green100,
      tagText: _C.green400,
      iconBg: _C.green100,
      iconColor: _C.green400,
    ),
  ];

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
                    _buildSummaryRow(),

                    const SizedBox(height: 14),

                    _buildChartBanner(context),

                    const SizedBox(height: 14),

                    _buildSectionTitle('Chi so cua ban'),

                    const SizedBox(height: 10),

                    ..._metrics.map((e) => _buildMetricCard(e)),

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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F4FB), Color(0xFFD8EEF9)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi so suc khoe',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _C.blue700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Cap nhat luc ${_timeNow()}',
                  style: const TextStyle(fontSize: 12, color: _C.textSub),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.blue200),
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
          '4',
          'Chi so tot',
        ),

        const SizedBox(width: 8),

        _summaryChip(
          Icons.warning_rounded,
          _C.amber100,
          _C.amber400,
          '1',
          'Can chu y',
        ),

        const SizedBox(width: 8),

        _summaryChip(
          Icons.calendar_today_rounded,
          _C.blue100,
          _C.blue400,
          'Hom nay',
          'Lan do gan nhat',
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),

            const SizedBox(height: 4),

            Text(
              val,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.blue700,
              ),
            ),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                color: _C.textHint,
                fontWeight: FontWeight.w600,
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
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: Colors.white),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Xem bieu do thong ke',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _C.blue700,
      ),
    );
  }

  Widget _buildMetricCard(_Metric m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: m.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(m.icon, color: m.iconColor),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: m.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _C.blue700,
                          ),
                        ),

                        TextSpan(
                          text: ' ${m.unit}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: m.tagBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    m.tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: m.tagText,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditDialog(m),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _C.blue100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: _C.blue700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () => _deleteMetric(m),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
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

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showAddDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.blue100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.blue200, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: _C.blue400),

            SizedBox(width: 8),

            Text(
              'Them chi so moi',
              style: TextStyle(fontWeight: FontWeight.w700, color: _C.blue700),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(_Metric metric) {
    final controller = TextEditingController(text: metric.value);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sua ${metric.name}'),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Gia tri moi',
            border: OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _metrics.indexOf(metric);

                _metrics[index] = _Metric(
                  id: metric.id,
                  icon: metric.icon,
                  name: metric.name,
                  value: controller.text,
                  unit: metric.unit,
                  tag: metric.tag,
                  tagBg: metric.tagBg,
                  tagText: metric.tagText,
                  iconBg: metric.iconBg,
                  iconColor: metric.iconColor,
                );
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cap nhat thanh cong')),
              );
            },
            child: const Text('Luu'),
          ),
        ],
      ),
    );
  }

  void _deleteMetric(_Metric metric) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoa chi so'),

        content: Text('Ban co chac muon xoa ${metric.name}?'),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _metrics.remove(metric);
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Da xoa chi so')));
            },
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Them chi so'),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ten chi so'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Gia tri'),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _metrics.add(
                  _Metric(
                    id: DateTime.now().millisecondsSinceEpoch,
                    icon: Icons.favorite_rounded,
                    name: nameController.text,
                    value: valueController.text,
                    unit: '',
                    tag: 'Moi',
                    tagBg: _C.blue100,
                    tagText: _C.blue700,
                    iconBg: _C.pink100,
                    iconColor: Colors.pink,
                  ),
                );
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Them thanh cong')));
            },
            child: const Text('Them'),
          ),
        ],
      ),
    );
  }

  String _timeNow() {
    final t = TimeOfDay.now();

    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
