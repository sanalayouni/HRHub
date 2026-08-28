import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/decisions_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/decision_card.dart';
import 'widgets/decision_filters.dart';

class DecisionHistoryScreen extends ConsumerWidget {
  const DecisionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsAsync = ref.watch(decisionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Decision History', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            const DecisionFiltersBar(),
            const SizedBox(height: 12),
            Expanded(
              child: decisionsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No decisions match these filters.', style: TextStyle(color: AppColors.inkSoft)),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(decisionsProvider),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => DecisionCard(item: items[index]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Couldn\'t load decisions: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
