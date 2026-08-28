import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/request_model.dart';
import '../theme/app_palette.dart';
import '../theme/labels.dart';
import 'category_badge.dart';
import 'status_badge.dart';

/// One row of the web's `DecisionTable`, folded into a card for narrow
/// screens. Used by both the Requests and Decisions lists.
class RequestRow extends StatelessWidget {
  final RequestListItem item;
  final bool showDivider;

  const RequestRow({super.key, required this.item, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ai = normalizeAiRecommendation(palette, item.aiRecommendation);

    return InkWell(
      onTap: () => context.push('/requests/${item.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: showDivider ? palette.creamSoft : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.employeeName ?? 'Unknown Employee',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: palette.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(item.createdAt),
                  style: TextStyle(fontSize: 11, color: palette.inkSoft),
                ),
              ],
            ),
            if (item.summary != null && item.summary!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: palette.inkSoft, height: 1.4),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CategoryBadge(category: item.requestType),
                StatusBadge(status: item.status),
                DotBadge(label: ai.label, color: ai.color),
                Text(
                  formatConfidence(item.confidence),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.inkSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
