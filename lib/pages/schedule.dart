import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/tablerows.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFE2E3DA),
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Outfit'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.t('page.schedule.title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 30),
                Text(
                  l10n.t('page.schedule.directSeeding'),
                  style: const TextStyle(
                    color: Color(0xFF00623A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                //Direct Seeded Table Widget
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Table(
                    border: const TableBorder(
                        horizontalInside: BorderSide(
                            width: 1,
                            color: Colors.grey,
                            style: BorderStyle.solid)),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // Growth Stage
                      1: FlexColumnWidth(1.5), // DAS
                      2: FlexColumnWidth(2.5), // Strategy
                    },
                    children: TableRows.buildDSRow(l10n),
                  ),
                ),
const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    l10n.t('page.schedule.safeAwdNote'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  l10n.t('page.schedule.transplanting'),
                  style: const TextStyle(
                    color: Color(0xFF00623A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                //Transplanting Table Widget
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Table(
                    border: const TableBorder(
                        horizontalInside: BorderSide(
                            width: 1,
                            color: Colors.grey,
                            style: BorderStyle.solid)),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // Growth Stage
                      1: FlexColumnWidth(1.5), // DAS
                      2: FlexColumnWidth(2.5), // Strategy
                    },
                    children: TableRows.buildTPRow(l10n),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
