import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:provider/provider.dart';

class IrrigationControlWidget extends StatelessWidget {
  const IrrigationControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context);
    final pump = formData.pumpStatus;
    final pumpOn = pump != 0;
    final isManualMode = formData.manualOverride;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 20),
            child: Text(
              l10n.t('irrigation.control'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
             // 👈 limit height here
            width: double.infinity, // 👈 takes full width of parent
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 4,
                        children: [
                          Text(
                            l10n.t('irrigation.status'),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            l10n.irrigationStatusText(pumpOn),
                            style: TextStyle(
                              color: pumpOn ? Colors.green : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isManualMode
                                  ? Colors.orange.withValues(alpha: 0.12)
                                  : Colors.indigo.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.irrigationModeText(isManualMode),
                              style: TextStyle(
                                color: isManualMode
                                    ? Colors.orange
                                    : Colors.indigo,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2878B5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        formData.manualControl();
                      },
                      child: Text(
                        pumpOn
                            ? l10n.t('action.turnOff')
                            : l10n.t('action.turnOn'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                
              ],
            )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                l10n.irrigationCurrentStatus(pumpOn),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: pumpOn ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        
      ],
      
    );
  }
}
