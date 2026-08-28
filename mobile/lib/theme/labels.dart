import 'package:flutter/material.dart';
import 'app_theme.dart';

const Map<String, String> categoryLabels = {
  'leave': 'Leave',
  'salary': 'Salary',
  'flexwork': 'Flexible Work',
};

Color categoryColor(String category) {
  switch (category) {
    case 'leave':
      return AppColors.dustyBlue;
    case 'salary':
      return AppColors.accent;
    case 'flexwork':
      return AppColors.sage;
    default:
      return AppColors.inkSoft;
  }
}

Color categoryBg(String category) {
  switch (category) {
    case 'leave':
      return AppColors.dustyBlueSoft;
    case 'salary':
      return AppColors.accent.withValues(alpha: 0.2);
    case 'flexwork':
      return AppColors.sageSoft;
    default:
      return AppColors.creamSoft;
  }
}

const Map<String, String> statusLabels = {
  'pending': 'Not Yet Reviewed',
  'needs_review': 'Needs Review',
  'approved': 'Approved',
  'rejected': 'Rejected',
};

Color statusColor(String status) {
  switch (status) {
    case 'approved':
      return AppColors.sage;
    case 'rejected':
      return AppColors.coral;
    default:
      return AppColors.dustyBlue;
  }
}

Color statusBg(String status) {
  switch (status) {
    case 'approved':
      return AppColors.sageSoft;
    case 'rejected':
      return AppColors.coralSoft;
    default:
      return AppColors.dustyBlueSoft;
  }
}

class AiRecommendation {
  final String label;
  final Color color;
  final Color bg;
  AiRecommendation(this.label, this.color, this.bg);
}

AiRecommendation normalizeAiRecommendation(String? raw) {
  if (raw == null) {
    return AiRecommendation('—', AppColors.inkSoft, AppColors.creamSoft);
  }
  final v = raw.toLowerCase();
  if (v.contains('approve')) {
    return AiRecommendation('Approve', AppColors.sage, AppColors.sageSoft);
  }
  if (v.contains('reject')) {
    return AiRecommendation('Reject', AppColors.coral, AppColors.coralSoft);
  }
  if (v.contains('info')) {
    return AiRecommendation('Request Info', AppColors.dustyBlue, AppColors.dustyBlueSoft);
  }
  return AiRecommendation(raw, AppColors.inkSoft, AppColors.creamSoft);
}

String formatConfidence(double? confidence) {
  if (confidence == null) return '—';
  return '${(confidence * 100).round()}%';
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  final letters = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join();
  return letters.toUpperCase();
}

String formatDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
