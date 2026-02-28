import 'package:flutter/material.dart';

/// A centered, card-based scaffold designed for auth pages on wide screens.
///
/// On desktop / web the content is constrained to [maxWidth] and wrapped in a
/// [Card] so it doesn't stretch across the entire viewport.
/// On narrow screens it simply fills the available width.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 420,
    this.actions,
  });

  /// Text shown in the [AppBar].
  final String title;

  /// The main content (typically a form column).
  final Widget child;

  /// Maximum width of the content card.
  final double maxWidth;

  /// Optional [AppBar] action buttons (e.g. logout).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
