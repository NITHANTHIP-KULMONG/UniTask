import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/preferences/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';

class UniTaskApp extends ConsumerWidget {
  const UniTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'UniTask',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // AuthGate is the single entry point:
      //  - Not logged in → LoginPage
      //  - Logged in + user  → UserHomePage
      //  - Logged in + admin → AdminHomePage
      home: const AuthGate(),
    );
  }
}