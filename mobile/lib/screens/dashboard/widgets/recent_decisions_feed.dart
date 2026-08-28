import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dashboard_summary_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/status_badge.dart';

class RecentDecisionsFeed extends StatelessWidget {
  final List<RecentDecisionItem> items;
  const RecentDecisionsFeed({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Decisions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No decisions made yet.', style: TextStyle(color: AppColors.inkSoft)),
                ),
              )
            else
              ...items.map((item) => InkWell(
                    onTap: () => context.push('/requests/${item.requestId}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CategoryBadge(category: item.requestType),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.employeeName ?? 'Unknown Employee',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            formatDate(item.updatedAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: item.status),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
