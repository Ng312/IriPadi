import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:flutter_application_1/widgets/growthStage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaddyFieldDataWidget extends StatefulWidget {
  const PaddyFieldDataWidget({
    super.key,
  });

  @override
  State<PaddyFieldDataWidget> createState() => _PaddyFieldDataWidgetState();
}

class _PaddyFieldDataWidgetState extends State<PaddyFieldDataWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context);
    final method = formData.method;
    final startDate = formData.startDate;

    if (startDate == null || method == null) {
      return const SizedBox.shrink();
    }

    final plantingDate = startDate;
    final now = DateTime.now();
    final int days = now.difference(plantingDate).inDays;
    final String growthStage = Growthstage.getGrowthStage(method, plantingDate);
    final String growthStageLabel =
        l10n.growthStageLabel(growthStage).isNotEmpty
            ? l10n.growthStageLabel(growthStage)
            : growthStage;

    // Avoid notifying listeners while the widget is building.
    if (formData.days != days) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formData.setDays(days);
      });
    }
    if (formData.growthStage != growthStage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formData.setGrowthStage(growthStage);
      });
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 20),
            child: Text(
              l10n.t('paddy.field'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.t('paddy.plantingDate'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6)),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(formData.startDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.t('paddy.days'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6)),
                      ),
                      Text(
                        days.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.t('paddy.growthStage'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7)),
                      ),
                      Text(
                        growthStageLabel,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF00623A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
