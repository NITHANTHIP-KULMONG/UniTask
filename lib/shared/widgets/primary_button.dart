import 'package:flutter/material.dart';

/// A reusable full-width button with built-in loading state.
///
/// Use this across the app whenever you need a prominent action button.
/// The [isLoading] flag disables the button and swaps the label for a spinner,
/// preventing double-taps during async operations.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  /// Text shown on the button.
  final String label;

  /// Called when the button is tapped (disabled while [isLoading] is true).
  final VoidCallback onPressed;

  /// When true, shows a spinner and disables the button.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label));

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
