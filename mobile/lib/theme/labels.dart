import 'package:flutter/material.dart';
import 'app_palette.dart';

const Map<String, String> categoryLabels = {
  'leave': 'Leave',
  'salary': 'Salary',
  'flexwork': 'Flexible Work',
};

Color categoryColor(AppPalette p, String category) {
  switch (category) {
    case 'leave':
      return p.dustyBlue;
    case 'salary':
      return p.accent;
    case 'flexwork':
      return p.sage;
    default:
      return p.inkSoft;
  }
}

Color categoryBg(AppPalette p, String category) {
  switch (category) {
    case 'leave':
      return p.dustyBlueSoft;
    case 'salary':
      return p.accent.withValues(alpha: 0.2);
    case 'flexwork':
      return p.sageSoft;
    default:
      return p.creamSoft;
  }
}

const Map<String, String> statusLabels = {
  'pending': 'Not Yet Reviewed',
  'needs_review': 'Needs Review',
  'approved': 'Approved',
  'rejected': 'Rejected',
};

Color statusColor(AppPalette p, String status) {
  switch (status) {
    case 'approved':
      return p.sage;
    case 'rejected':
      return p.coral;
    default:
      return p.dustyBlue;
  }
}

Color statusBg(AppPalette p, String status) {
  switch (status) {
    case 'approved':
      return p.sageSoft;
    case 'rejected':
      return p.coralSoft;
    default:
      return p.dustyBlueSoft;
  }
}

class AiRecommendation {
  final String label;
  final Color color;
  final Color bg;
  AiRecommendation(this.label, this.color, this.bg);
}

AiRecommendation normalizeAiRecommendation(AppPalette p, String? raw) {
  if (raw == null) {
    return AiRecommendation('—', p.inkSoft, p.creamSoft);
  }
  final v = raw.toLowerCase();
  if (v.contains('approve')) {
    return AiRecommendation('Approve', p.sage, p.sageSoft);
  }
  if (v.contains('reject')) {
    return AiRecommendation('Reject', p.coral, p.coralSoft);
  }
  if (v.contains('info')) {
    return AiRecommendation('Request Info', p.dustyBlue, p.dustyBlueSoft);
  }
  return AiRecommendation(raw, p.inkSoft, p.creamSoft);
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

String formatSalary(double salary) {
  final whole = salary.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '\$$buffer';
}
