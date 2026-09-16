import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/locale_provider.dart';
import 'package:flutter_application_1/widgets/language_option_card.dart';
import 'package:flutter_application_1/widgets/styled_dialog.dart';

class FieldInfoPage extends StatelessWidget {
  const FieldInfoPage({super.key});

  Future<void> _startNewPlanting(BuildContext context) async {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context, listen: false);
    final proceed = await showStyledDialog<bool>(
          context: context,
          title: l10n.t('page.fieldInfo.dialogTitle'),
          message: l10n.t('page.fieldInfo.dialogBody'),
          primaryLabel: l10n.t('language.continue'),
          onPrimary: () => Navigator.of(context).pop(true),
          icon: Icons.autorenew,
          primaryColor: const Color(0xFF00623A),
          iconColor: const Color(0xFF00623A),
          gradientTop: const Color(0xFFEFF9FF),
          gradientBottom: Colors.white,
          secondaryLabel: l10n.t('action.cancel'),
          onSecondary: () => Navigator.of(context).pop(false),
        ) ??
        false;

    if (!context.mounted) return;
    if (!proceed) return;

    await formData.resetFieldData();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _openEditSheet(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context, listen: false);
    final locationController =
        TextEditingController(text: formData.location ?? '');
    final dateController = TextEditingController(
      text: formData.startDate != null
          ? DateFormat('dd/MM/yyyy').format(formData.startDate!)
          : '',
    );
    String? selectedMethod = formData.method;
    DateTime? selectedDate = formData.startDate;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            textTheme: Theme.of(ctx).textTheme.apply(fontFamily: 'Outfit'),
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFEFF9FF), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00623A).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_calendar,
                                  color: Color(0xFF00623A)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.t('page.fieldInfo.editTitle'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: locationController,
                          decoration: InputDecoration(
                              labelText: l10n.t('form.location')),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField2<String>(
                          value: selectedMethod,
                          decoration: InputDecoration(
                              labelText: l10n.t('form.plantingMethod')),
                          items: [
                            DropdownMenuItem(
                                value: 'Direct Seeding',
                                child: Text(l10n.t('method.directSeeding'))),
                            DropdownMenuItem(
                                value: 'Transplanting',
                                child: Text(l10n.t('method.transplanting'))),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              selectedMethod = value;
                            });
                          },
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 250,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.t('form.startDate'),
                            suffixIcon: const Icon(Icons.date_range),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                                dateController.text =
                                    DateFormat('dd/MM/yyyy').format(picked);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                      Colors.black.withValues(alpha: 0.7),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(l10n.t('action.cancel')),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                formData.setLocation(
                                    locationController.text.trim());
                                if (selectedMethod != null) {
                                  formData.setMethod(selectedMethod!);
                                }
                                if (selectedDate != null) {
                                  formData.setStartDate(selectedDate!);
                                }
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 4,
                                backgroundColor: const Color(0xFF00623A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(l10n.t('action.save')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;
    final currentLanguage = currentLangCode == 'zh'
        ? l10n.t('language.chinese')
        : currentLangCode == 'ms'
            ? l10n.t('language.malay')
            : l10n.t('language.english');

    // Format date if available
    final formattedDate = formData.startDate != null
        ? DateFormat('dd/MM/yyyy').format(formData.startDate!)
        : l10n.t('page.fieldInfo.notSet');
    final methodLabel = () {
      final method = formData.method;
      if (method == null) return l10n.t('page.fieldInfo.notSet');
      if (method == 'Direct Seeding') return l10n.t('method.directSeeding');
      if (method == 'Transplanting') return l10n.t('method.transplanting');
      return method;
    }();
    void _showLanguageDialog() {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE6F4FF),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('language.settingTitle'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.t('language.settingNote'),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LanguageOptionCard(
                    label: l10n.t('language.english'),
                    flag: '🇺🇸',
                    selected: currentLangCode == 'en',
                    onTap: () {
                      localeProvider.setLocale(const Locale('en'));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  LanguageOptionCard(
                    label: l10n.t('language.malay'),
                    flag: '🇲🇾',
                    selected: currentLangCode == 'ms',
                    onTap: () {
                      localeProvider.setLocale(const Locale('ms'));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  LanguageOptionCard(
                    label: l10n.t('language.chinese'),
                    flag: '🇨🇳',
                    selected: currentLangCode == 'zh',
                    onTap: () {
                      localeProvider.setLocale(const Locale('zh'));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E3DA),
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Outfit', color: Colors.black),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                    tooltip:
                        '${l10n.t('language.settingTitle')}: $currentLanguage',
                    icon: const Icon(Icons.translate),
                    onPressed: _showLanguageDialog,
                  ),
                ),
                // Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.t('page.fieldInfo.title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 2.5, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openEditSheet(context),
                        child: Text(l10n.t('action.edit'),
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black.withValues(alpha: 0.6)))),
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.edit),
                      onPressed: () => _openEditSheet(context),
                    ),
                  ],
                ),

                // Location
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('form.location'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formData.location ?? l10n.t('page.fieldInfo.notSet'),
                        style: const TextStyle(
                            color: Color(0xFF00623A),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 30),

                      // Planting Method
                      Text(
                        l10n.t('form.plantingMethod'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        methodLabel,
                        style: const TextStyle(
                            color: Color(0xFF00623A),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 30),

                      // Start Date
                      Text(
                        l10n.t('form.startDate'),
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            color: Color(0xFF00623A),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),

                      SizedBox(height: 50),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _startNewPlanting(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00623A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      l10n.t('page.fieldInfo.startNewPlanting'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
