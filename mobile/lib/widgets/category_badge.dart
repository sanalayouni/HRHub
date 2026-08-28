import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/labels.dart';

/// Pill with a coloured dot and label — matches the web `CategoryBadge`.
class DotBadge extends StatelessWidget {
  final String label;
  final Color color;

  const DotBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.creamSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;
  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return DotBadge(
      label: categoryLabels[category] ?? category,
      color: categoryColor(context.palette, category),
    );
  }
}
