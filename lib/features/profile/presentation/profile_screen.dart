import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../auth/services/auth_service.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../../timer/domain/pomodoro_preferences.dart';
import '../../timer/services/study_session_service.dart';
import '../../timer/domain/study_session.dart';

// =============================================================================
// Derived providers for profile stats
// =============================================================================

/// Total study time across ALL sessions (work only), in seconds.
final totalStudySecondsProvider = Provider<int>((ref) {
  final sessions = ref.watch(userStudySessionsProvider).valueOrNull ?? [];
  return sessions
      .where((s) => s.sessionType == SessionType.work)
      .fold<int>(0, (sum, s) => sum + s.durationSeconds.clamp(0, 999999));
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
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: appUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final firebaseUser =
              ref.read(authServiceProvider).currentUser;
          final isGoogle = firebaseUser?.providerData
                  .any((p) => p.providerId == 'google.com') ??
              false;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // ════════════════════════════════════════════════════════════════
              // ACCOUNT SECTION
              // ════════════════════════════════════════════════════════════════
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ── Avatar ──
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                _initial(user.name, user.email),
                                style: tt.headlineLarge
                                    ?.copyWith(color: cs.onPrimaryContainer),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Display name (editable) ──
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showEditNameDialog(context, ref, user.name),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : 'Set your name',
                                  style: tt.titleLarge?.copyWith(
                                    color: user.name.isNotEmpty
                                        ? null
                                        : cs.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.edit_outlined,
                                  size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Email (read-only) ──
                      Text(
                        user.email,
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),

                      // ── Provider badge ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGoogle ? Icons.g_mobiledata : Icons.email_outlined,
                              size: 18,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isGoogle ? 'Google' : 'Email / Password',
                              style: tt.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),

                      // ── Role badge ──
                      if (user.isAdmin) ...[
                        const SizedBox(height: 8),
                        Chip(
                          label: Text('Admin',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onTertiaryContainer)),
                          backgroundColor: cs.tertiaryContainer,
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ════════════════════════════════════════════════════════════════
              // PREFERENCES SECTION
              // ════════════════════════════════════════════════════════════════
              _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    // ── Theme mode ──
                    _ThemeModeTile(),
                    const Divider(height: 1),

                    // ── Default study duration ──
                    _StudyDurationTile(),
                    const Divider(height: 1),

                    // ── First day of week ──
                    _FirstDayOfWeekTile(),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ════════════════════════════════════════════════════════════════
              // STATS SECTION
              // ════════════════════════════════════════════════════════════════
              _SectionHeader(title: 'Stats'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      label: 'Study Time',
                      value: _formatDuration(ref.watch(totalStudySecondsProvider)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Completed',
                      value: '${ref.watch(completedTaskCountProvider)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Joined',
                      value: DateFormat('MMM yyyy').format(user.createdAt),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ════════════════════════════════════════════════════════════════
              // ACTIONS SECTION
              // ════════════════════════════════════════════════════════════════
              _SectionHeader(title: 'Actions'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, ref),
                icon: Icon(Icons.delete_forever_outlined, color: cs.error),
                label: Text('Delete Account',
                    style: TextStyle(color: cs.error)),
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

  // ── Helpers ──

  String _initial(String name, String email) {
    if (name.isNotEmpty) return name[0].toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  // ── Dialogs ──

  Future<void> _showEditNameDialog(
      BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your name',
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentName) {
      try {
        await ref.read(authServiceProvider).updateDisplayName(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Display name updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update name: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteAccountDialog(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).deleteAccount();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      }
    }
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
            Text(value,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        mode == ThemeMode.dark
            ? Icons.dark_mode_outlined
            : mode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.brightness_auto_outlined,
        color: cs.primary,
      ),
      title: const Text('Theme'),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 18)),
          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).state = s.first,
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// =============================================================================
// Study Duration Tile
// =============================================================================

class _StudyDurationTile extends ConsumerWidget {
  static const _options = [15, 20, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(pomodoroPrefsProvider);

    return ListTile(
      leading: Icon(Icons.timer_outlined,
          color: Theme.of(context).colorScheme.primary),
      title: const Text('Study Duration'),
      subtitle: Text('${prefs.workMinutes} min per session'),
      trailing: PopupMenuButton<int>(
        initialValue: prefs.workMinutes,
        onSelected: (v) => ref.read(pomodoroPrefsProvider.notifier).state =
            prefs.copyWith(workMinutes: v),
        itemBuilder: (_) => _options.map((m) {
          return PopupMenuItem(value: m, child: Text('$m minutes'));
        }).toList(),
        child: Chip(
          label: Text('${prefs.workMinutes}m'),
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
  static const _days = {
    1: 'Monday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(firstDayOfWeekProvider);

    return ListTile(
      leading: Icon(Icons.calendar_today_outlined,
          color: Theme.of(context).colorScheme.primary),
      title: const Text('Week Starts On'),
      trailing: PopupMenuButton<int>(
        initialValue: day,
        onSelected: (v) =>
            ref.read(firstDayOfWeekProvider.notifier).state = v,
        itemBuilder: (_) => _days.entries.map((e) {
          return PopupMenuItem(value: e.key, child: Text(e.value));
        }).toList(),
        child: Chip(
          label: Text(_days[day] ?? 'Monday'),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
