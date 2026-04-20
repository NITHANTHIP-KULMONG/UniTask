import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_loading_screen.dart';
import '../services/auth_service.dart';
import '../../dashboard/presentation/home_shell.dart';
import 'login_page.dart';

/// Root widget that gates the app on auth state.
///
/// Uses Riverpod's [authStateProvider] (a cached StreamProvider) so the
/// stream is never recreated on rebuilds — this prevents the flash-of-
/// login-page problem on web refresh.
///
///  - Loading        → spinner
///  - user == null   → [LoginPage]
///  - user != null   → [HomeShell]
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final l10n = context.l10n;

    return authState.when(
      // Still resolving the persisted login session.
      loading: () => AppLoadingScreen(message: l10n.authCheckingSession),
      // Stream error (rare) — show message + retry.
      error: (e, _) => Scaffold(
        body: Center(child: Text(l10n.authGenericError('$e'))),
      ),
      // Auth state resolved.
      data: (user) {
        if (user != null) return const HomeShell();
        return const LoginPage();
      },
    );
  }
}
