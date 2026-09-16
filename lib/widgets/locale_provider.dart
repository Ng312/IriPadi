import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider() {
    _loadLocale();
  }

  static const _localeKey = 'app_locale';

  Locale _locale = const Locale('en');
  Locale? _userLocale;
  bool _hydrated = false;

  Locale get locale => _userLocale ?? _locale;
  bool get isHydrated => _hydrated;
  bool get hasSelectedLocale => _userLocale != null;

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_localeKey);
      if (saved != null && saved.isNotEmpty) {
        _userLocale = Locale(saved);
      }
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _userLocale = locale;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
