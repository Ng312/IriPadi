import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:flutter_application_1/widgets/locale_provider.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  Future<void> _select(BuildContext context, Locale locale) async {
    final localeProvider = context.read<LocaleProvider>();
    final formData = context.read<FormDataProvider>();
    await localeProvider.setLocale(locale);
    if (!context.mounted) return;
    if (formData.hasSavedFieldData) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFE2E3DA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                l10n.t('language.title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.t('language.subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 40),
              _LanguageCard(
                flag: '🇺🇸',
                title: l10n.t('language.english'),
                subtitle: 'English',
                onTap: () => _select(context, const Locale('en')),
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                flag: '🇲🇾',
                title: l10n.t('language.malay'),
                subtitle: 'Bahasa Melayu',
                onTap: () => _select(context, const Locale('ms')),
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                flag: '🇨🇳',
                title: l10n.t('language.chinese'),
                subtitle: '中文',
                onTap: () => _select(context, const Locale('zh')),
              ),
              const Spacer(),
              Text(
                'IriPadi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 24,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String flag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
