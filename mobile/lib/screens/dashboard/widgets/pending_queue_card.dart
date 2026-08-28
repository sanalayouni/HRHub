import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';

class PendingQueueCard extends StatelessWidget {
  final List<RequestListItem> requests;
  const PendingQueueCard({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Requests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "Nothing waiting on you right now.",
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                ),
              )
            else
              ...requests.take(6).map((req) {
                final ai = normalizeAiRecommendation(req.aiRecommendation);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/requests/${req.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CategoryBadge(category: req.requestType),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      req.employeeName ?? 'Unknown Employee',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                req.summary ?? 'No summary available',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ai.bg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ai.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ai.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatConfidence(req.confidence),
                          style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
