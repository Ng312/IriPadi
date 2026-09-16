import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class TableRows {
  static List<TableRow> buildDSRow(AppLocalizations l10n) {
    return [
      TableRow(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        children: [
          _buildCell(l10n.t('schedule.header.growthStage'), firstRow: true),
          _buildCell(l10n.t('schedule.header.days'), firstRow: true),
          _buildCell(l10n.t('schedule.header.strategy'), firstRow: true),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Germination')),
          _buildCell('0-3'),
          _buildCell(l10n.t('strategy.Flood')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Emergence')),
          _buildCell('4-10'),
          _buildCell(l10n.t('strategy.ShallowWater')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Pre-AWD Transition')),
          _buildCell('11 - 14'),
          _buildCell(
              l10n.t('strategy.AWDDelay')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Early Vegetative')),
          _buildCell('15 - 24'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Tilllering')),
          _buildCell('25 - 44'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Panicle Initiation')),
          _buildCell('45 - 64'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Flowering')),
          _buildCell('65 - 70'),
          _buildCell(l10n.t('strategy.Ponded')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Grain Filing')),
          _buildCell('71 - 100'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Ripening')),
          _buildCell('101 - 109'),
          _buildCell(l10n.t('strategy.StopIrrigation')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Harvest')),
          _buildCell('~ 110'),
          _buildCell(l10n.t('strategy.DryField')),
        ],
      ),
    ];
  }

  static List<TableRow> buildTPRow(AppLocalizations l10n) {
    return [
      TableRow(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        children: [
          _buildCell(l10n.t('schedule.header.growthStage'), firstRow: true),
          _buildCell(l10n.t('schedule.header.days'), firstRow: true),
          _buildCell(l10n.t('schedule.header.strategy'), firstRow: true),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Transplanting')),
          _buildCell('0'),
          _buildCell(l10n.t('strategy.Flood')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Germination')),
          _buildCell('1-4'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Early Vegetative')),
          _buildCell('5-7'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Vegetative Growth')),
          _buildCell('8–24'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Active Tillering')),
          _buildCell('25–44'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Panicle Initiation')),
          _buildCell('45–64'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Flowering')),
          _buildCell('65–70'),
          _buildCell(l10n.t('strategy.Ponded')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Grain Filing')),
          _buildCell('71-100'),
          _buildCell(l10n.t('strategy.SafeAWD')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Ripening')),
          _buildCell('101–109'),
          _buildCell(l10n.t('strategy.StopIrrigation')),
        ],
      ),
      TableRow(
        children: [
          _buildCell(l10n.t('stage.Harvest')),
          _buildCell('~110'),
          _buildCell(l10n.t('strategy.DryField')),
        ],
      ),
    ];
  }

  static Widget _buildCell(String text, {bool firstRow =false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Text(text,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: firstRow
              ? const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600)
              : const TextStyle(fontSize: 14, color: Colors.black)),
    );
  }
}
