import 'package:flutter/material.dart';

class CustomSegmentedControl<T> extends StatelessWidget {
  const CustomSegmentedControl({
    super.key,
    required this.groupValue,
    required this.onValueChanged,
    required this.children,
  });

  final T groupValue;
  final ValueChanged<T> onValueChanged;
  final Map<T, Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children.entries.map((entry) {
          final isSelected = groupValue == entry.key;
          return GestureDetector(
            onTap: () => onValueChanged(entry.key),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                child: IconTheme(
                  data: IconThemeData(
                    size: 18,
                    color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                  child: entry.value,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
