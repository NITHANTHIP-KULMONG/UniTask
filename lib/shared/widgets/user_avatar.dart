import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
    this.fallbackText,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double radius;
  final String? photoUrl;
  final String? fallbackText;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final normalizedUrl = _normalizePhotoUrl(photoUrl);
    final hasPhoto = normalizedUrl != null;
    final bg = backgroundColor ?? cs.surfaceContainerHighest;
    final fg = foregroundColor ?? cs.onSurfaceVariant;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: hasPhoto
              ? Image.network(
                  normalizedUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _AvatarPlaceholder(
                      radius: radius,
                      foregroundColor: fg,
                      fallbackText: fallbackText,
                      fallbackIcon: fallbackIcon,
                      isLoading: true,
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return _AvatarPlaceholder(
                      radius: radius,
                      foregroundColor: fg,
                      fallbackText: fallbackText,
                      fallbackIcon: fallbackIcon,
                    );
                  },
                )
              : _AvatarPlaceholder(
                  radius: radius,
                  foregroundColor: fg,
                  fallbackText: fallbackText,
                  fallbackIcon: fallbackIcon,
                ),
        ),
      ),
    );
  }

  String? _normalizePhotoUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({
    required this.radius,
    required this.foregroundColor,
    required this.fallbackText,
    required this.fallbackIcon,
    this.isLoading = false,
  });

  final double radius;
  final Color foregroundColor;
  final String? fallbackText;
  final IconData fallbackIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final initial = _resolveInitial(fallbackText);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (initial != null)
          Text(
            initial,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.7,
            ),
          )
        else
          Icon(
            fallbackIcon,
            color: foregroundColor,
            size: radius,
          ),
        if (isLoading)
          SizedBox(
            width: radius * 0.9,
            height: radius * 0.9,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
      ],
    );
  }

  String? _resolveInitial(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.substring(0, 1).toUpperCase();
  }
}
