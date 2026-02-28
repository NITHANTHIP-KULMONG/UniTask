import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final email = appUserAsync.whenOrNull(
          data: (u) => u?.email,
        ) ??
        '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          // Admin badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: Icon(Icons.shield, size: 16, color: cs.onTertiaryContainer),
              label: Text('Admin',
                  style: TextStyle(
                      fontSize: 12, color: cs.onTertiaryContainer)),
              backgroundColor: cs.tertiaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.checklist), text: 'All Tasks'),
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
              'Signed in as $email',
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

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: 'Failed to load users.\n$e',
        onRetry: () => ref.invalidate(allUsersProvider),
      ),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
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
    final isAdmin = user.isAdmin;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : user.email.isNotEmpty
                      ? user.email[0].toUpperCase()
                      : '?')
              : null,
        ),
        title: Text(user.name.isNotEmpty ? user.name : user.email),
        subtitle: Text(user.email),
        trailing: Chip(
          label: Text(
            isAdmin ? 'Admin' : 'User',
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

// =============================================================================
// All Tasks tab
// =============================================================================

class _AllTasksTab extends ConsumerWidget {
  const _AllTasksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: 'Failed to load tasks.\n$e',
        onRetry: () => ref.invalidate(allTasksProvider),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found.'));
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
    final statusColor = switch (task.status) {
      TaskStatus.todo => cs.outline,
      TaskStatus.doing => cs.primary,
      TaskStatus.done => Colors.green,
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
          'Owner: ${task.ownerId.substring(0, 8)}…',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(task.status.label,
              style: const TextStyle(fontSize: 11)),
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
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
