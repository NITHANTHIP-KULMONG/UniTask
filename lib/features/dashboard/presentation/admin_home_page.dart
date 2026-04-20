import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../auth/models/app_user.dart';
import '../../auth/services/auth_service.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';

/// Admin dashboard with two tabs: Users and Tasks.
///
/// This page is shown only when `appUser.role == admin`.
/// Both tabs stream data in real time from Firestore.
/// Firestore security rules ensure only admins can read all users / tasks.
class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appUserAsync = ref.watch(appUserProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    final email = appUserAsync.whenOrNull(
          data: (u) => u?.email,
        ) ??
        '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboardTitle),
        centerTitle: true,
        actions: [
          // Admin badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar:
                  Icon(Icons.shield, size: 16, color: cs.onTertiaryContainer),
              label: Text(l10n.adminRoleAdmin,
                  style:
                      TextStyle(fontSize: 12, color: cs.onTertiaryContainer)),
              backgroundColor: cs.tertiaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.commonSignOut,
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(icon: const Icon(Icons.people_outline), text: l10n.adminTabUsers),
            Tab(icon: const Icon(Icons.checklist), text: l10n.adminTabAllTasks),
          ],
        ),
      ),
      body: Column(
        children: [
          // Subtle header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            color: cs.tertiaryContainer.withValues(alpha: 0.2),
            child: Text(
              l10n.adminSignedInAs(email),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _UsersTab(),
                _AllTasksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Users tab
// =============================================================================

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final l10n = context.l10n;

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: l10n.adminUsersLoadFailed('$e'),
        onRetry: () => ref.invalidate(allUsersProvider),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(child: Text(l10n.adminUsersEmpty));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _UserTile(user: users[i]),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isAdmin = user.isAdmin;
    final photoUrl = _normalizePhotoUrl(user.photoUrl);
    final fallbackInitial = user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : user.email.isNotEmpty
            ? user.email[0].toUpperCase()
            : '?';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: Text(fallbackInitial),
        ),
        title: Text(user.name.isNotEmpty ? user.name : user.email),
        subtitle: Text(user.email),
        trailing: Chip(
          label: Text(
            isAdmin ? l10n.adminRoleAdmin : l10n.adminRoleUser,
            style: TextStyle(
              fontSize: 11,
              color: isAdmin ? cs.onTertiaryContainer : cs.onSurfaceVariant,
            ),
          ),
          backgroundColor:
              isAdmin ? cs.tertiaryContainer : cs.surfaceContainerHighest,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

String? _normalizePhotoUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

// =============================================================================
// All Tasks tab
// =============================================================================

class _AllTasksTab extends ConsumerWidget {
  const _AllTasksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksProvider);
    final l10n = context.l10n;

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: l10n.adminTasksLoadFailed('$e'),
        onRetry: () => ref.invalidate(allTasksProvider),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(child: Text(l10n.adminTasksEmpty));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _AdminTaskTile(task: tasks[i]),
        );
      },
    );
  }
}

class _AdminTaskTile extends StatelessWidget {
  const _AdminTaskTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final statusColor = switch (task.status) {
      TaskStatus.todo => cs.outline,
      TaskStatus.doing => cs.primary,
      TaskStatus.done => Colors.green,
    };
    final statusLabel = switch (task.status) {
      TaskStatus.todo => l10n.taskStatusPending,
      TaskStatus.doing => l10n.taskStatusInProgress,
      TaskStatus.done => l10n.taskStatusCompleted,
    };

    return Card(
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        title: Text(
          task.title,
          style: task.status == TaskStatus.done
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(
          l10n.adminTaskOwner(task.userId.substring(0, 8)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(statusLabel, style: const TextStyle(fontSize: 11)),
          backgroundColor: statusColor.withValues(alpha: 0.15),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

// =============================================================================
// Shared error view
// =============================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
