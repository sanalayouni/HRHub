import 'package:flutter/material.dart';
import '../theme/labels.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: categoryBg(category),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        categoryLabels[category] ?? category,
        style: TextStyle(
          color: categoryColor(category),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
