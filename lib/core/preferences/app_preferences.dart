import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'app_theme_mode';

/// App-wide theme mode persisted locally.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModePrefKey);

    state = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString(_themeModePrefKey, raw);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

/// First day of the week — used by calendar-related features.
///
/// 1 = Monday (ISO 8601 default), 7 = Sunday.
final firstDayOfWeekProvider = StateProvider<int>((ref) => 1); // Monday

const _localePrefKey = 'app_locale_code';

/// App language selection persisted locally.
///
/// Defaults to System language and supports English/Thai per product UX.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);
    if (code == null || (code != 'en' && code != 'th')) return;
    state = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    if (state?.languageCode == locale?.languageCode) return;
    if (locale != null &&
        locale.languageCode != 'en' &&
        locale.languageCode != 'th') return;

    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localePrefKey);
    } else {
      await prefs.setString(_localePrefKey, locale.languageCode);
    }
  }
}

final appLocaleProvider = StateNotifierProvider<LocaleController, Locale?>((
  ref,
) {
  return LocaleController();
});
