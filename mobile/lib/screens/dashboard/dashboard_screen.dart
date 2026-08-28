import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/requests_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/category_donut.dart';
import 'widgets/pending_queue_card.dart';
import 'widgets/recent_decisions_feed.dart';
import 'widgets/stat_pill.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final pendingAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(pendingRequestsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const Text('Welcome back, HR Manager', style: TextStyle(color: AppColors.inkSoft)),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) => StatPillRow(
                pending: summary.pendingCount,
                approvedThisWeek: summary.approvedThisWeekCount,
                rejected: summary.rejectedCount,
                totalEmployees: summary.totalEmployees,
              ),
              loading: () => const SizedBox(height: 90, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Couldn\'t load stats: $e'),
            ),
            const SizedBox(height: 16),
            pendingAsync.when(
              data: (requests) => PendingQueueCard(requests: requests),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Couldn\'t load requests: $e'),
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) => CategoryDonut(split: summary.categorySplit),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) => RecentDecisionsFeed(items: summary.recentDecisions),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
