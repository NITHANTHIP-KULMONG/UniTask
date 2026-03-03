import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  Widget build(BuildContext context) {
    final appUserAsync = ref.watch(appUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: appUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.profileLoadFailed('$e'))),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final firebaseUser = ref.read(authServiceProvider).currentUser;
          final providerIds =
              firebaseUser?.providerData.map((p) => p.providerId).toSet() ??
                  const <String>{};
          final isGoogle = providerIds.contains('google.com');
          final isPasswordProvider = providerIds.contains('password');

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
                      InkWell(
                        borderRadius: BorderRadius.circular(44),
                        onTap: _isUploadingAvatar
                            ? null
                            : () => _showAvatarPicker(context),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      _initial(user.name, user.email),
                                      style: tt.headlineLarge?.copyWith(
                                        color: cs.onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isUploadingAvatar)
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: cs.surface.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: cs.primary,
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 14,
                                    color: cs.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.password_outlined, color: cs.primary),
                      title: Text(l10n.profileChangePassword),
                      subtitle: Text(l10n.profileChangePasswordDescription),
                      onTap: () => _handlePasswordReset(
                        email: user.email,
                        isPasswordProvider: isPasswordProvider,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.alternate_email_outlined,
                        color: cs.primary,
                      ),
                      title: Text(l10n.profileChangeEmail),
                      subtitle: Text(l10n.profileChangeEmailDescription),
                      onTap: () => _showChangeEmailDialog(
                        currentEmail: user.email,
                        isPasswordProvider: isPasswordProvider,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.read(authServiceProvider).signOut(),
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

  Future<void> _showAvatarPicker(BuildContext context) async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.profileChangeAvatar)),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(l10n.profileTakePhoto),
                  onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.profileChooseFromGallery),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (file == null) return;

    await _uploadAvatar(file);
  }

  Future<void> _uploadAvatar(XFile file) async {
    final l10n = context.l10n;
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final bytes = await file.readAsBytes();
      final contentType = _guessContentType(file.name);
      final fileExt = _safeExtension(file.name);

      final storageRef = FirebaseStorage.instance.ref().child(
            'users/${user.uid}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt',
          );

      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      final downloadUrl = await storageRef.getDownloadURL();
      await ref.read(authServiceProvider).updatePhotoUrl(downloadUrl);

      if (mounted) {
        _showSnackBar(l10n.profileAvatarUpdated);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.profileAvatarUpdateFailed('$e'));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  String _safeExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.toLowerCase();
    if (ext.isEmpty) return 'jpg';
    return ext;
  }

  String _guessContentType(String filename) {
    final ext = _safeExtension(filename);
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
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

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).deleteAccount();
      } catch (e) {
        if (mounted) {
          _showSnackBar(l10n.profileDeleteAccountFailed('$e'));
        }
      }
    }
  }

  Future<void> _handlePasswordReset({
    required String email,
    required bool isPasswordProvider,
  }) async {
    final l10n = context.l10n;

    if (!isPasswordProvider) {
      _showSnackBar(l10n.profileChangePasswordUnavailable);
      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        _showSnackBar(l10n.profilePasswordResetSent(email));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnackBar(
          l10n.profilePasswordResetFailed(_mapAuthError(context, e)),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.profilePasswordResetFailed('$e'));
      }
    }
  }

  Future<void> _showChangeEmailDialog({
    required String currentEmail,
    required bool isPasswordProvider,
  }) async {
    final l10n = context.l10n;

    if (!isPasswordProvider) {
      _showSnackBar(l10n.profileChangeEmailUnavailable);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: currentEmail);

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileChangeEmail),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: l10n.profileCurrentPasswordLabel,
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.profileFieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: l10n.profileNewEmailLabel,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.profileFieldRequired;
                  }
                  final email = v.trim();
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return l10n.profileInvalidEmail;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(ctx).pop(true);
            },
            child: Text(l10n.profileSendVerificationEmail),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) {
      passwordCtrl.dispose();
      emailCtrl.dispose();
      return;
    }

    try {
      await ref.read(authServiceProvider).sendEmailChangeVerification(
            currentPassword: passwordCtrl.text.trim(),
            newEmail: emailCtrl.text.trim(),
          );
      if (mounted) {
        _showSnackBar(l10n.profileEmailVerificationSent(emailCtrl.text.trim()));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnackBar(l10n.profileEmailChangeFailed(_mapAuthError(context, e)));
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.profileEmailChangeFailed('$e'));
      }
    }
    passwordCtrl.dispose();
    emailCtrl.dispose();
  }

  String _mapAuthError(BuildContext context, FirebaseAuthException e) {
    final l10n = context.l10n;
    return switch (e.code) {
      'wrong-password' => l10n.profileAuthWrongPassword,
      'invalid-credential' => l10n.profileAuthInvalidCredential,
      'email-already-in-use' => l10n.profileAuthEmailInUse,
      'invalid-email' => l10n.profileAuthInvalidEmail,
      'requires-recent-login' => l10n.profileAuthRequiresRecentLogin,
      'network-request-failed' => l10n.profileAuthNetwork,
      'too-many-requests' => l10n.profileAuthTooManyRequests,
      'user-disabled' => l10n.profileAuthUserDisabled,
      _ => l10n.profileAuthGeneric(e.code),
    };
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

    return ListTile(
      leading: Icon(
        mode == ThemeMode.dark
            ? Icons.dark_mode_outlined
            : mode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.brightness_auto_outlined,
        color: cs.onSurface,
      ),
      title: Text(l10n.profileTheme),
      trailing: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(Icons.light_mode, size: 18),
            label: Text(l10n.profileThemeLight),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: const Icon(Icons.brightness_auto, size: 18),
            label: Text(l10n.profileThemeSystem),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(Icons.dark_mode, size: 18),
            label: Text(l10n.profileThemeDark),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).state = s.first,
        showSelectedIcon: false,
        style: const ButtonStyle(
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
          return PopupMenuItem(value: m, child: Text('$m min'));
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
    final current = locale.languageCode == 'th' ? 'th' : 'en';

    String labelForCode(String code) {
      return code == 'th' ? l10n.profileLanguageTh : l10n.profileLanguageEn;
    }

    return ListTile(
      leading: Icon(Icons.public, color: cs.onSurface),
      title: Text(l10n.profileLanguage),
      trailing: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(value: 'en', label: Text('EN')),
          ButtonSegment<String>(value: 'th', label: Text('TH')),
        ],
        selected: {current},
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          final code = selection.first;
          ref.read(appLocaleProvider.notifier).setLocale(Locale(code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.profileLanguageChanged(labelForCode(code)),
              ),
            ),
          );
        },
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
