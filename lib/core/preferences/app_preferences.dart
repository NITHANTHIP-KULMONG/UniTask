import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide theme mode — Light / Dark / System.
///
/// Stored in-memory; survives navigation but resets on full page reload.
/// Ready to persist to SharedPreferences or Firestore user prefs later.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// First day of the week — used by calendar-related features.
///
/// 1 = Monday (ISO 8601 default), 7 = Sunday.
final firstDayOfWeekProvider = StateProvider<int>((ref) => 1); // Monday
