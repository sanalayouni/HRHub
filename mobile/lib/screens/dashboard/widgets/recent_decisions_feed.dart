import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dashboard_summary_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/status_badge.dart';

class RecentDecisionsFeed extends StatelessWidget {
  final List<RecentDecisionItem> items;
  const RecentDecisionsFeed({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Decisions', style: heading(size: 15, color: palette.ink)),
          const SizedBox(height: 4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No decisions made yet.',
                  style: TextStyle(fontSize: 13, color: palette.inkSoft),
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++)
              InkWell(
                onTap: () => context.push('/requests/${items[i].requestId}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i < items.length - 1
                            ? palette.creamSoft.withValues(alpha: 0.6)
                            : Colors.transparent,
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
                              items[i].employeeName ?? 'Unknown Employee',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: palette.ink,
                              ),
                            ),
                          ),
                          Text(
                            formatDate(items[i].updatedAt),
                            style: TextStyle(fontSize: 11, color: palette.inkSoft),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          CategoryBadge(category: items[i].requestType),
                          StatusBadge(status: items[i].status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
