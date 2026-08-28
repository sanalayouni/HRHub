import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/labels.dart';
import 'category_badge.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return DotBadge(
      label: statusLabels[status] ?? status,
      color: statusColor(context.palette, status),
    );
  }
}
