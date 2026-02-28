import 'package:flutter/material.dart';

// =============================================================================
// UniTask SaaS Theme
// =============================================================================
//
// Design principles:
//  1. **Neutral background** — light grey surface so content cards pop.
//  2. **Single primary colour** — deep indigo for actions & focus rings.
//  3. **Consistent spacing** — 8-point grid throughout.
//  4. **Professional typography** — system font stack with clear hierarchy.
//  5. **Flat cards** — zero elevation with subtle border, modern SaaS look.

/// The single source of truth for all visual styling in UniTask.
///
/// Usage in `app.dart`:
/// ```dart
/// theme: AppTheme.light,
/// ```
abstract final class AppTheme {
  // ── Brand colours ──
  static const _seed = Color(0xFF4F46E5); // Indigo-600
  static const _neutral = Color(0xFFF8FAFC); // Slate-50

  // ── Light theme ──
  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _neutral,

    // ── Typography ──
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(height: 1.5),
      bodyMedium: TextStyle(height: 1.5),
      bodySmall: TextStyle(height: 1.5),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),

    // ── AppBar ──
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: _neutral,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B), // Slate-800
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF475569)), // Slate-600
    ),

    // ── Cards ──
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    // ── Input fields ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // Slate-300
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _seed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)), // Red-500
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF64748B)), // Slate-500
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate-400
      prefixIconColor: const Color(0xFF94A3B8),
    ),

    // ── Filled buttons (primary actions) ──
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── Outlined buttons (secondary actions) ──
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ── Text buttons ──
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // ── FAB ──
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // ── Chips ──
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),

    // ── Navigation bar (bottom) ──
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // ── Tab bar ──
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      dividerHeight: 1,
    ),

    // ── Dialogs ──
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    ),

    // ── SnackBar ──
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    // ── Dividers ──
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      space: 1,
    ),
  );

  // ── Dark theme ──
  static final dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate-900

    // ── Typography ──
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(height: 1.5),
      bodyMedium: TextStyle(height: 1.5),
      bodySmall: TextStyle(height: 1.5),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),

    // ── AppBar ──
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF0F172A),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E8F0), // Slate-200
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFF94A3B8)), // Slate-400
    ),

    // ── Cards ──
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF334155)), // Slate-700
      ),
      color: const Color(0xFF1E293B), // Slate-800
      surfaceTintColor: Colors.transparent,
    ),

    // ── Input fields ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF475569)), // Slate-600
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _seed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      prefixIconColor: const Color(0xFF64748B),
    ),

    // ── Filled buttons ──
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── Outlined buttons ──
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF475569)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ── Text buttons ──
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // ── FAB ──
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // ── Chips ──
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),

    // ── Navigation bar ──
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // ── Tab bar ──
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      dividerHeight: 1,
    ),

    // ── Dialogs ──
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E8F0),
      ),
    ),

    // ── SnackBar ──
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    // ── Dividers ──
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),
  );
}
