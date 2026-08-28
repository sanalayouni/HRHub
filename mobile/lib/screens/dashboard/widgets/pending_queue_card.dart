import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/glass_card.dart';

class PendingQueueCard extends StatelessWidget {
  final List<RequestListItem> requests;
  const PendingQueueCard({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pending Requests', style: heading(size: 15, color: palette.ink)),
              const Spacer(),
              if (requests.isNotEmpty)
                TextButton(
                  onPressed: () => context.go('/requests'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.inkSoft,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Nothing waiting on you right now.',
                  style: TextStyle(fontSize: 13, color: palette.inkSoft),
                ),
              ),
            )
          else
            ...requests.take(6).map((req) {
              final ai = normalizeAiRecommendation(palette, req.aiRecommendation);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: palette.cream,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/requests/${req.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  req.employeeName ?? 'Unknown Employee',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: palette.ink,
                                  ),
                                ),
                              ),
                              Text(
                                formatConfidence(req.confidence),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.summary ?? 'No summary available',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.inkSoft,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              CategoryBadge(category: req.requestType),
                              DotBadge(label: ai.label, color: ai.color),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
