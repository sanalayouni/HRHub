import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: foreground.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
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
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          StatPill(
            label: 'Pending',
            value: '$pending',
            background: AppColors.accent,
            foreground: AppColors.ink,
          ),
          const SizedBox(width: 10),
          StatPill(
            label: 'Approved This Week',
            value: '$approvedThisWeek',
            background: AppColors.sageSoft,
            foreground: AppColors.sage,
          ),
          const SizedBox(width: 10),
          StatPill(
            label: 'Rejected',
            value: '$rejected',
            background: AppColors.coralSoft,
            foreground: AppColors.coral,
          ),
          const SizedBox(width: 10),
          StatPill(
            label: 'Total Employees',
            value: '$totalEmployees',
            background: AppColors.ink,
            foreground: AppColors.cream,
          ),
        ],
      ),
    );
  }
}
