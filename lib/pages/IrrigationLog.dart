import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class IrrigationLogPage extends StatefulWidget {
  const IrrigationLogPage({super.key});

  @override
  State<IrrigationLogPage> createState() => _HomePageState();
}

class _HomePageState extends State<IrrigationLogPage> {
  final DatabaseService dbService = DatabaseService();
  bool _isInitialized = false;
  String _filter = 'all';
  final List<String> _filters = const [
    'all',
    'today',
    'last3',
    'last7',
    'older'
  ];

  String _filterLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'today':
        return l10n.t('log.filter.today');
      case 'last3':
        return l10n.t('log.filter.last3Days');
      case 'last7':
        return l10n.t('log.filter.last7Days');
      case 'older':
        return l10n.t('log.filter.older');
      default:
        return l10n.t('log.filter.all');
    }
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFE2E3DA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E3DA),
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Outfit', color: Colors.black),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.t('page.irrigationLog.title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.filter_list, color: Colors.black.withValues(alpha:0.6)),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          value: _filter,
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 20,
                          ),
                          buttonStyleData: ButtonStyleData(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            height: 36,
                            width: 140,
                            
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 220,
                            width: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.75)),
                          items: _filters
                              .map((f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      _filterLabel(f, l10n),
                                      style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _filter = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                //Direct Seeded Table Widget
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: StreamBuilder(
                      stream: dbService.getDataStream(),
                      builder: (context, snapshot) {
                        final now = DateTime.now();
                        final dateFmt = DateFormat('yyyy-MM-dd');
                        final timeFmt = DateFormat('HH:mm');
                        final sampleRecords = [
                          {
                            'date': dateFmt.format(now),
                            'time': timeFmt.format(now.subtract(const Duration(minutes: 5))),
                            'ts': now.subtract(const Duration(minutes: 5)),
                            'status': 'OFF',
                            'waterLevel': 5,
                          },
                          {
                            'date': dateFmt.format(now.subtract(const Duration(hours: 1))),
                            'time': timeFmt.format(now.subtract(const Duration(hours: 1))),
                            'ts': now.subtract(const Duration(hours: 1)),
                            'status': 'ON',
                            'waterLevel': 1,
                          },
                          {
                            'date': dateFmt.format(now.subtract(const Duration(days: 1))),
                            'time': timeFmt.format(now.subtract(const Duration(days: 1, hours: 2))),
                            'ts': now.subtract(const Duration(days: 1, hours: 2)),
                            'status': 'ON',
                            'waterLevel': -3,
                          },
                        ];
                        bool usingSample = false;

                        Widget buildTable(List<Map<String, dynamic>> rows,
                            {required String emptyMessage,
                            required AppLocalizations l10n}) {
                          final headerRows = [
                            TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 2),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 1),
                                  child: Text(
                                    l10n.t('log.header.date'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 1),
                                  child: Text(
                                    l10n.t('log.header.time'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 8),
                                  child: Text(
                                    l10n.t('log.header.waterLevel'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 8),
                                  child: Text(
                                    l10n.t('log.header.irrigation'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ];

                          if (rows.isEmpty) {
                            return Column(
                              children: [
                                Table(
                                  border: const TableBorder(
                                    horizontalInside: BorderSide(
                                        width: 1, color: Colors.grey),
                                  ),
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(1),
                                  },
                                  children: headerRows,
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    emptyMessage,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }

                          return Table(
                            border: const TableBorder(
                              horizontalInside:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              ...headerRows,
                              ...rows.map((item) {
                                final status =
                                    (item['status'] ?? '').toString();
                                final isOn = status.toUpperCase() == 'ON';
                                final statusColor =
                                    isOn ? Colors.green : Colors.red;
                                final statusLabel =
                                    (status.toUpperCase() == 'ON' ||
                                            status.toUpperCase() == 'OFF')
                                        ? l10n.irrigationStatusText(isOn)
                                        : status;
                                final rawWater = item['waterLevel'];
                                num? waterValue;
                                if (rawWater is num) {
                                  waterValue = rawWater;
                                } else if (rawWater is String) {
                                  waterValue = num.tryParse(rawWater);
                                }
                                final waterLabel = waterValue == null
                                    ? '-'
                                    : l10n.waterLevelWithUnit(waterValue);
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 1),
                                      child: Text(
                                        '${item['date']}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 1),
                                      child: Text(
                                        '${item['time']}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: Text(
                                        waterLabel,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: Text(
                                        statusLabel,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          );
                        }

                        List<Map<String, dynamic>> records = [];
                        if (snapshot.hasData &&
                            !snapshot.hasError &&
                            snapshot.data != null) {
                          final data = (snapshot.data!).snapshot.value;
                          if (data is Map) {
                            final Map<dynamic, dynamic> values =
                                Map<dynamic, dynamic>.from(data);

                            records = values.entries
                                .map((e) {
                                  final item =
                                      Map<dynamic, dynamic>.from(e.value);
                                  final date = item['date']?.toString();
                                  final time = item['time']?.toString();
                                  final ts = (date != null && time != null)
                                      ? DateTime.tryParse('$date $time')
                                      : null;
                                  if (ts == null) return null;
                                  return {
                                    'date': date,
                                    'time': time,
                                    'ts': ts,
                                    'status': (item['status'] ?? '').toString(),
                                    'waterLevel': item['current_water_level'] ?? item['currentWaterLevel'],
                                  };
                                })
                                .whereType<Map<String, dynamic>>()
                                .toList();
                          }
                        }

                        if (records.isEmpty) {
                          records = sampleRecords;
                          usingSample = true;
                        }

                        List<Map<String, dynamic>> filtered = records;
                        switch (_filter) {
                          case 'today':
                            filtered = records
                                .where((r) =>
                                    (r['ts'] as DateTime).day == now.day &&
                                    (r['ts'] as DateTime).month ==
                                        now.month &&
                                    (r['ts'] as DateTime).year == now.year)
                                .toList();
                            break;
                          case 'last3':
                            final cutoff = now.subtract(const Duration(days: 3));
                            filtered = records
                                .where((r) =>
                                    (r['ts'] as DateTime).isAfter(cutoff))
                                .toList();
                            break;
                          case 'last7':
                            final cutoff = now.subtract(const Duration(days: 7));
                            filtered = records
                                .where((r) =>
                                    (r['ts'] as DateTime).isAfter(cutoff))
                                .toList();
                            break;
                          case 'older':
                            final cutoff = now.subtract(const Duration(days: 7));
                            filtered = records
                                .where((r) =>
                                    (r['ts'] as DateTime).isBefore(cutoff))
                                .toList();
                            break;
                          default:
                            break;
                        }

                        filtered.sort((a, b) =>
                            (b['ts'] as DateTime).compareTo(a['ts'] as DateTime));

                        if (filtered.isEmpty && !usingSample) {
                          return buildTable(const [],
                              emptyMessage: l10n.t('log.empty'),
                              l10n: l10n);
                        }

                        final table = buildTable(
                          filtered.isEmpty ? sampleRecords : filtered,
                          emptyMessage: l10n.t('log.empty'),
                          l10n: l10n,
                        );

                        return Column(
                          children: [
                            table,
                            if (usingSample || filtered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 12),
                                child: Text(
                                  l10n.t('log.sampleNote'),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        );
                      },
                    )),

                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
