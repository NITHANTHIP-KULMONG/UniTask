import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme mode — Light / Dark / System.
///
/// Stored in-memory; survives navigation but resets on full page reload.
/// Ready to persist to SharedPreferences or Firestore user prefs later.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// First day of the week — used by calendar-related features.
///
/// 1 = Monday (ISO 8601 default), 7 = Sunday.
final firstDayOfWeekProvider = StateProvider<int>((ref) => 1); // Monday

const _localePrefKey = 'app_locale_code';

/// App language selection persisted locally.
///
/// Defaults to English and supports only English/Thai per product UX.
class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);
    if (code == null || (code != 'en' && code != 'th')) return;
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    if (locale.languageCode != 'en' && locale.languageCode != 'th') return;

    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, locale.languageCode);
  }
}

final appLocaleProvider = StateNotifierProvider<LocaleController, Locale>((
  ref,
) {
  return LocaleController();
});
