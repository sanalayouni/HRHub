import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/requests_provider.dart';
import '../../widgets/page_header.dart';
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
    final me = ref.watch(meProvider).valueOrNull;
    final name = me?.displayName ?? 'HR Manager';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(pendingRequestsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          PageHeader(
            title: 'Dashboard',
            subtitle: 'Welcome back, ${name[0].toUpperCase()}${name.substring(1)}',
          ),
          summaryAsync.when(
            data: (summary) => StatPillRow(
              pending: summary.pendingCount,
              approvedThisWeek: summary.approvedThisWeekCount,
              rejected: summary.rejectedCount,
              totalEmployees: summary.totalEmployees,
            ),
            loading: () => const SizedBox(
              height: 170,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ListMessage(
              apiErrorMessage(e, fallback: "Couldn't load stats."),
            ),
          ),
          const SizedBox(height: 16),
          pendingAsync.when(
            data: (requests) => PendingQueueCard(requests: requests),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ListMessage(
              apiErrorMessage(e, fallback: "Couldn't load requests."),
            ),
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
    );
  }
}
