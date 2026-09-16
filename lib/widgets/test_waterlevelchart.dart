import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/database/database_service.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/widgets/styled_dialog.dart';
import 'package:intl/intl.dart';

class TestWaterlevelchart extends StatefulWidget {
  const TestWaterlevelchart({super.key});

  @override
  State<TestWaterlevelchart> createState() => _TestWaterlevelchartState();
}

class _TestWaterlevelchartState extends State<TestWaterlevelchart> {
  final DatabaseService dbService = DatabaseService();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _sampleDialogShown = false;
  static const bool _enableSampleNoteDialog = false; // temporary

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final raw = value.toInt();
      // Support seconds-based values while migrating to milliseconds.
      final ms = raw < 1000000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (value is String) {
      try {
        return dateFormat.parse(value);
      } catch (_) {
        return DateTime.tryParse(value);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await DatabaseService.ensureUserSignedIn();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = DateTime.now();
    final header = Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, top: 20),
        child: Text(
          l10n.t('log.header.waterLevelgraph'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );

    if (!_isInitialized) {
      return Column(
        children: [
          header,
          const SizedBox(height: 10),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return Column(
      children: [
        header,
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: StreamBuilder<DatabaseEvent>(
            stream: dbService.getDataStreamForDay(today),
            builder: (context, snapshot) {
              String? overlayMessage;
              List<FlSpot> spots = const [];
              double targetLevel = 5.0;
              double minX = 0;
              double maxX = 6;
              double minY = 0;
              double maxY = 10;
              double? currentLevel;
	              bool hasLiveData = false;

	              void _maybeShowSampleDialog() {
	                // Temporarily disabled.
	                if (!_enableSampleNoteDialog) return;

	                // Only show the sample note when there is truly no live data.
	                // This avoids popping a dialog during initial stream loading or
	                // when the database contains data (e.g., previous days) but not
	                // for the selected day.
	                if (snapshot.connectionState == ConnectionState.waiting) return;
	                if (hasLiveData) return;
	                if (_sampleDialogShown) return;
	                _sampleDialogShown = true;
	                WidgetsBinding.instance.addPostFrameCallback((_) {
	                  if (!mounted) return;
	                  // Re-check in case live data arrived after this build.
	                  if (hasLiveData) {
	                    _sampleDialogShown = false;
	                    return;
	                  }
	                  if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
	                    _sampleDialogShown = false;
	                    _maybeShowSampleDialog();
	                    return;
	                  }
                  showStyledDialog<void>(
                    context: context,
                    title: l10n.t('waterlevel.sampleTitle'),
                    message: l10n.t('waterlevel.sampleDescription'),
                    primaryLabel: l10n.t('action.ok'),
                    onPrimary: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    primaryColor: const Color(0xFF00623A),
                    icon: Icons.info_rounded,
                    iconColor: const Color(0xFF00623A),
                    gradientTop: const Color(0xFFEFF9FF),
                    gradientBottom: Colors.white,
                  );
                });
              }

              void applySampleData() {
                final hours = <double>[8, 10, 12, 14, 16, 18];
                final levels = <double>[-5,-2,0,2,4.2,5];
                targetLevel = 5.0;
                spots = List.generate(
                  hours.length,
                  (i) => FlSpot(hours[i], levels[i]),
                );
                minX = spots.first.x;
                maxX = spots.last.x;
                final yValues = <double>[...spots.map((e) => e.y), targetLevel];
                const interval = 5.0;
                final minRaw = yValues.reduce((a, b) => a < b ? a : b) - 2;
                final maxRaw = yValues.reduce((a, b) => a > b ? a : b) + 2;
                minY = (minRaw / interval).floor() * interval;
                maxY = (maxRaw / interval).ceil() * interval;
                currentLevel = spots.last.y;
                overlayMessage = null;
                _maybeShowSampleDialog();
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data?.snapshot.value == null) {
                applySampleData();
              } else {
                final data = snapshot.data!.snapshot.value;
                if (data is Map) {
                  final Map<dynamic, dynamic> values = data;
                  hasLiveData = values.isNotEmpty;

                  final List<Map<String, dynamic>> allData =
                      values.entries.map((e) {
                    final item = Map<dynamic, dynamic>.from(e.value);
                    final rawLevel =
                        item['current_water_level'] ?? item['currentWaterLevel'];
                    return {
                      'timestamp': item['timestamp'],
                      'current_water_level': _toDouble(rawLevel) ?? 0.0,
                      // Accept a few possible keys for the model's threshold output.
                      'threshold': _toDouble(
                        item['threshold'] ??
                            item['threshold_cm'] ??
                            item['targetLevel'],
                      ),
                    };
                  }).toList();

                  final dayFormat = DateFormat('yyyy-MM-dd');
                  final target = dayFormat.format(today);
                  final todayData = allData.where((item) {
                    final ts = _parseTimestamp(item['timestamp']);
                    if (ts == null) return false;
                    return dayFormat.format(ts) == target;
                  }).toList();

                  final parsedData = todayData
                      .map((item) {
                        final ts = _parseTimestamp(item['timestamp']);
                        if (ts == null) return null;
                        return {
                          'ts': ts,
                          'level': item['current_water_level'] as double,
                          'threshold': item['threshold'] as double?,
                        };
                      })
                      .whereType<Map<String, dynamic>>()
                      .toList()
                    ..sort(
                      (a, b) =>
                          (a['ts'] as DateTime).compareTo(b['ts'] as DateTime),
                    );

                  if (parsedData.isEmpty) {
                    applySampleData();
                  } else {
                    spots = parsedData
                        .map((item) => FlSpot(
                              (item['ts'] as DateTime).hour +
                                  (item['ts'] as DateTime).minute / 60.0,
                              item['level'] as double,
                            ))
                        .toList();

                    final modelThreshold = parsedData
                        .map((item) => item['threshold'] as double?)
                        .lastWhere((value) => value != null, orElse: () => null);
                    targetLevel = modelThreshold ?? 5.0;
                    targetLevel = targetLevel >= 0 ? 5.0 : -15.0;

                    minX = spots.isNotEmpty ? spots.first.x : 0;
                    maxX = spots.isNotEmpty ? spots.last.x : 6;
                    final yValues = spots.isNotEmpty
                        ? <double>[...spots.map((e) => e.y), targetLevel]
                        : <double>[0, targetLevel];
                    const interval = 5.0;
                    final minRaw = yValues.reduce((a, b) => a < b ? a : b) - 2;
                    final maxRaw = yValues.reduce((a, b) => a > b ? a : b) + 2;
                    minY = (minRaw / interval).floor() * interval;
                    maxY = (maxRaw / interval).ceil() * interval;
                    currentLevel = spots.isNotEmpty ? spots.last.y : null;
                  }
                } else {
                  applySampleData();
                }
              }

              const chartHeight = 220.0;
              const chartPadding = 12.0;
              const bottomTitlesReserved = 28.0;
              final axisHeight =
                  chartHeight - chartPadding * 2 - bottomTitlesReserved;
              final chartWidth = MediaQuery.of(context).size.width * 2;
              const interval = 5.0;
              final yTicks = <double>[];
              for (double y = maxY; y >= minY; y -= interval) {
                yTicks.add(y);
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                }
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: chartHeight,
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 44,
                              child: Stack(
                                children: yTicks.map((v) {
                                  final span =
                                      maxY - minY == 0 ? 1 : maxY - minY;
                                  final unit = axisHeight / span;
                                  final top = chartPadding + (maxY - v) * unit;
                                  return Positioned(
                                    top: top - 8, // approximate half text height
                                    right: 0,
                                    child: Text(
                                      l10n.waterLevelWithUnit(v.toInt()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: chartWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.all(chartPadding),
                                    child: LineChart(
                                      LineChartData(
                                        minX: minX,
                                        maxX: maxX,
                                        minY: minY,
                                        maxY: maxY,
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: true,
                                          horizontalInterval: interval,
                                          getDrawingHorizontalLine: (value) =>
                                              FlLine(
                                            color: Colors.grey.shade300,
                                            strokeWidth: 1,
                                          ),
                                          getDrawingVerticalLine: (value) =>
                                              FlLine(
                                            color: Colors.grey.shade200,
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 34,
                                              interval: ((maxX - minX) / 4)
                                                  .clamp(0.5, 4.0),
                                              getTitlesWidget: (value, meta) {
                                                final hour = value.floor();
                                                final minute = ((value - hour) *
                                                        60)
                                                    .round();
                                                final time = TimeOfDay(
                                                    hour: hour,
                                                    minute: minute);
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Text(
                                                    time
                                                        .format(context)
                                                        .toLowerCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: spots,
                                        isCurved: false,
                                            color: Colors.blue,
                                            barWidth: 2,
                                            dotData: FlDotData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: [
                                              FlSpot(minX, targetLevel),
                                              FlSpot(maxX, targetLevel),
                                            ],
                                            isCurved: false,
                                            color: Colors.orange,
                                            barWidth: 1.5,
                                            dotData: FlDotData(show: false),
                                            dashArray: [6, 4],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (overlayMessage != null)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.6),
                              child: Center(
                                child: Text(
                                  overlayMessage!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  Text(
                    '${l10n.t('waterlevel.current')} : ${currentLevel == null ? '-' : l10n.waterLevelWithUnit(currentLevel!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${l10n.t('waterlevel.target')} : ${overlayMessage != null ? '-' : l10n.waterLevelWithUnit(targetLevel)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
