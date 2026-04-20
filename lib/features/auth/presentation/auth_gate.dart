import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_loading_screen.dart';
import '../services/auth_service.dart';
import '../../tasks/presentation/user_home_page.dart';
import 'login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final l10n = context.l10n;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: authState.when(
        loading: () => AppLoadingScreen(
          key: const ValueKey('auth-loading'),
          message: l10n.authCheckingSession,
        ),
        error: (error, _) => Scaffold(
          key: const ValueKey('auth-error'),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.authUnexpectedError('$error'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        data: (user) {
          final isLoggedIn = user != null;
          if (!isLoggedIn) {
            return const LoginPage(key: ValueKey('login-screen'));
          }
          return const HomeScreen(key: ValueKey('home-screen'));
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserHomePage();
  }
}
