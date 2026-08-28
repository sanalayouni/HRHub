import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/status_badge.dart';

class DecisionCard extends StatelessWidget {
  final RequestListItem item;
  const DecisionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final ai = normalizeAiRecommendation(item.aiRecommendation);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/requests/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryBadge(category: item.requestType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.employeeName ?? 'Unknown Employee',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ai.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      ai.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ai.color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(formatConfidence(item.confidence), style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                  const Spacer(),
                  Text(formatDate(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
