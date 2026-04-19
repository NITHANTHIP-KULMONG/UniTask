import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitask/l10n/app_localizations.dart';

import 'core/preferences/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/presentation/landing_page.dart';

class UniTaskApp extends ConsumerWidget {
  const UniTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: 'UniTask',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: (settings) {
        if (settings.name == '/landingpage') {
          return MaterialPageRoute<void>(
            builder: (_) => const LandingPage(),
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => const AuthGate(),
        );
      },
    );
  }
}
