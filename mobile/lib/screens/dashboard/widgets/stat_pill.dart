import 'package:flutter/material.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';

class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color foreground;

  const StatPill({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: foreground.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 2),
          Text(value, style: heading(size: 24, weight: FontWeight.w800, color: foreground)),
        ],
      ),
    );
  }
}

class StatPillRow extends StatelessWidget {
  final int pending;
  final int approvedThisWeek;
  final int rejected;
  final int totalEmployees;

  const StatPillRow({
    super.key,
    required this.pending,
    required this.approvedThisWeek,
    required this.rejected,
    required this.totalEmployees,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pills = [
      StatPill(
        label: 'Pending',
        value: '$pending',
        background: palette.accent,
        foreground: palette.inkFixed,
      ),
      StatPill(
        label: 'Approved This Week',
        value: '$approvedThisWeek',
        background: palette.sageSoft,
        foreground: palette.sage,
      ),
      StatPill(
        label: 'Rejected',
        value: '$rejected',
        background: palette.coralSoft,
        foreground: palette.coral,
      ),
      StatPill(
        label: 'Total Employees',
        value: '$totalEmployees',
        background: palette.ink,
        foreground: palette.cream,
      ),
    ];

    // Two-up grid rather than the web's single row — four pills don't fit
    // side by side on a phone.
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: pills[0]),
            const SizedBox(width: 10),
            Expanded(child: pills[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: pills[2]),
            const SizedBox(width: 10),
            Expanded(child: pills[3]),
          ],
        ),
      ],
    );
  }
}
