import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../shared/widgets/app_loading_screen.dart';
import '../../../shared/widgets/custom_segmented_control.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../../timer/domain/pomodoro_preferences.dart';
import '../../timer/domain/study_session.dart';
import '../../timer/services/study_session_service.dart';

// =============================================================================
// Derived providers for profile stats
// =============================================================================

/// Total study time across ALL sessions (work only), in seconds.
final totalStudySecondsProvider = Provider<int>((ref) {
  final sessions = ref.watch(userStudySessionsProvider).valueOrNull ?? [];
  return sessions.where((s) => s.sessionType == SessionType.work).fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds.clamp(0, 999999).toInt(),
      );
});

/// Count of completed (done) tasks.
final completedTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(userTasksProvider).valueOrNull ?? [];
  return tasks.where((t) => t.status == TaskStatus.done).length;
});

// =============================================================================
// ProfileScreen
// =============================================================================

/// Professional profile page with Account, Preferences, Stats, and Actions.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final appUserAsync = ref.watch(appUserProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: appUserAsync.when(
        loading: () => AppLoadingScreen(message: l10n.profileLoading),
        error: (e, _) => Center(child: Text(l10n.profileLoadFailed('$e'))),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final photoUrl = _normalizePhotoUrl(user.photoUrl) ??
              _normalizePhotoUrl(authUser?.photoURL);

          final providerIds =
              authUser?.providerData.map((p) => p.providerId).toSet() ??
                  const <String>{};
          final isGoogle = providerIds.contains('google.com');

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _SectionHeader(title: l10n.profileSectionAccount),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      UserAvatar(
                        radius: 52,
                        photoUrl: photoUrl,
                        fallbackText: user.name,
                        fallbackIcon: Icons.person,
                        backgroundColor: cs.surfaceContainerHighest,
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showEditNameDialog(context, user.name),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : l10n.profileSetYourName,
                                  style: tt.titleLarge?.copyWith(
                                    color: user.name.isNotEmpty
                                        ? null
                                        : cs.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: cs.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGoogle
                                  ? Icons.g_mobiledata
                                  : Icons.email_outlined,
                              size: 18,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isGoogle
                                  ? l10n.profileProviderGoogle
                                  : l10n.profileProviderEmailPassword,
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            l10n.profileAdminBadge,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                          backgroundColor: cs.tertiaryContainer,
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: l10n.profileSectionPreferences),
              const SizedBox(height: 12),
              const Card(
                child: Column(
                  children: [
                    _ThemeModeTile(),
                    Divider(height: 1),
                    _StudyDurationTile(),
                    Divider(height: 1),
                    _FirstDayOfWeekTile(),
                    Divider(height: 1),
                    _LanguageTile(),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: l10n.profileSectionStats),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      label: l10n.profileStatStudyTime,
                      value: _formatDuration(
                        context,
                        ref.watch(totalStudySecondsProvider),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_outline,
                      label: l10n.profileStatCompleted,
                      value: '${ref.watch(completedTaskCountProvider)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month_outlined,
                      label: l10n.profileStatJoined,
                      value: DateFormat(
                        'MMM yyyy',
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(user.createdAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: l10n.profileSectionActions),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
                label: Text(l10n.commonSignOut),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context),
                icon: Icon(Icons.delete_forever_outlined, color: cs.error),
                label: Text(
                  l10n.profileDeleteAccount,
                  style: TextStyle(color: cs.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(BuildContext context, int totalSeconds) {
    final l10n = context.l10n;
    if (totalSeconds < 60) return l10n.profileDurationSeconds(totalSeconds);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return l10n.profileDurationHoursMinutes(hours, minutes);
    return l10n.profileDurationMinutes(minutes);
  }

  String? _normalizePhotoUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileEditDisplayNameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.profileDisplayNameLabel,
            hintText: l10n.profileDisplayNameHint,
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && result.isNotEmpty && result != currentName) {
      try {
        await ref.read(authServiceProvider).updateDisplayName(result);
        if (mounted) {
          _showSnackBar(l10n.profileDisplayNameUpdated);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(l10n.profileDisplayNameUpdateFailed('$e'));
        }
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteAccountTitle),
        content: Text(l10n.profileDeleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n.profileDeleteForever),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var loadingShown = false;
    if (mounted) {
      loadingShown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(context.l10n.profileDeletingAccount)),
            ],
          ),
        ),
      );
    }

    try {
      await ref.read(authServiceProvider).deleteAccount();
      await ref.read(authServiceProvider).signOut();

      if (loadingShown && rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (!mounted) return;
      _goToLoginWithMessage(l10n.profileAccountDeleted);
    } on FirebaseAuthException catch (e) {
      if (loadingShown && rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (e.code == 'requires-recent-login') {
        await ref.read(authServiceProvider).signOut();
        if (!mounted) return;
        _goToLoginWithMessage(l10n.profileReauthBeforeDelete);
        return;
      }

      if (mounted) {
        _showSnackBar(l10n.profileDeleteAccountFailed('$e'));
      }
    } catch (e) {
      if (loadingShown && rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (mounted) {
        _showSnackBar(l10n.profileDeleteAccountFailed('$e'));
      }
    }
  }

  void _goToLoginWithMessage(String message) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: LoginPage(initialSnackBarMessage: message),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
      (_) => false,
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const LoginPage(),
          ),
          transitionDuration: const Duration(milliseconds: 280),
        ),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(context.l10n.profileSignOutFailed('$e'));
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// =============================================================================
// Section Header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
    );
  }
}

// =============================================================================
// Stat Card
// =============================================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Theme Mode Tile
// =============================================================================

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    final themeIcon = Icon(
      mode == ThemeMode.dark
          ? Icons.dark_mode_outlined
          : mode == ThemeMode.light
              ? Icons.light_mode_outlined
              : Icons.brightness_auto_outlined,
      color: cs.onSurface,
    );

    final themeModeSelector = SizedBox(
      height: 38,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: CustomSegmentedControl<ThemeMode>(
          groupValue: mode,
          onValueChanged: (v) =>
              ref.read(themeModeProvider.notifier).setThemeMode(v),
          children: {
            ThemeMode.light: Row(
              children: [
                const Icon(Icons.light_mode, size: 16),
                const SizedBox(width: 6),
                Text(l10n.profileThemeLight),
              ],
            ),
            ThemeMode.system: Row(
              children: [
                const Icon(Icons.brightness_auto, size: 16),
                const SizedBox(width: 6),
                Text(l10n.profileThemeSystem),
              ],
            ),
            ThemeMode.dark: Row(
              children: [
                const Icon(Icons.dark_mode, size: 16),
                const SizedBox(width: 6),
                Text(l10n.profileThemeDark),
              ],
            ),
          },
        ),
      ),
    );

    if (isCompactWidth) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                themeIcon,
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.profileTheme,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: themeModeSelector,
            ),
          ],
        ),
      );
    }

    return ListTile(
      leading: themeIcon,
      title: Text(
        l10n.profileTheme,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: themeModeSelector,
    );
  }
}

// =============================================================================
// Study Duration Tile
// =============================================================================

class _StudyDurationTile extends ConsumerWidget {
  const _StudyDurationTile();

  static const _options = [15, 20, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(pomodoroPrefsProvider);
    final l10n = context.l10n;

    return ListTile(
      leading: Icon(
        Icons.timer_outlined,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(l10n.profileStudyDuration),
      subtitle: Text(l10n.profileStudyDurationSubtitle(prefs.workMinutes)),
      trailing: PopupMenuButton<int>(
        initialValue: prefs.workMinutes,
        onSelected: (v) => ref.read(pomodoroPrefsProvider.notifier).state =
            prefs.copyWith(workMinutes: v),
        itemBuilder: (_) => _options.map((m) {
          return PopupMenuItem(
            value: m,
            child: Text(l10n.profileMinutesOption(m)),
          );
        }).toList(),
        child: Chip(
          label: Text(l10n.profileMinutesShort(prefs.workMinutes)),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

// =============================================================================
// First Day of Week Tile
// =============================================================================

class _FirstDayOfWeekTile extends ConsumerWidget {
  const _FirstDayOfWeekTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(firstDayOfWeekProvider);
    final l10n = context.l10n;

    final days = {
      1: l10n.profileWeekdayMonday,
      6: l10n.profileWeekdaySaturday,
      7: l10n.profileWeekdaySunday,
    };

    return ListTile(
      leading: Icon(
        Icons.calendar_today_outlined,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(l10n.profileWeekStartsOn),
      trailing: PopupMenuButton<int>(
        initialValue: day,
        onSelected: (v) => ref.read(firstDayOfWeekProvider.notifier).state = v,
        itemBuilder: (_) => days.entries.map((e) {
          return PopupMenuItem(value: e.key, child: Text(e.value));
        }).toList(),
        child: Chip(
          label: Text(days[day] ?? l10n.profileWeekdayMonday),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final current = locale?.languageCode == 'th'
        ? 'th'
        : locale?.languageCode == 'en'
            ? 'en'
            : Localizations.localeOf(context).languageCode == 'th'
                ? 'th'
                : 'en';

    String labelForCode(String code) {
      return code == 'th' ? l10n.profileLanguageTh : l10n.profileLanguageEn;
    }

    return ListTile(
      leading: Icon(Icons.public, color: cs.onSurface),
      title: Text(l10n.profileLanguage),
      trailing: CustomSegmentedControl<String>(
        groupValue: current,
        onValueChanged: (code) {
          ref.read(appLocaleProvider.notifier).setLocale(Locale(code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.profileLanguageChanged(labelForCode(code)),
              ),
            ),
          );
        },
        children: {
          'en': Text(l10n.profileLanguageCodeEn),
          'th': Text(l10n.profileLanguageCodeTh),
        },
      ),
    );
  }
}
