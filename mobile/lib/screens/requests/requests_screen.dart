import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/requests_provider.dart';
import '../../widgets/folder_card.dart';
import '../../widgets/page_header.dart';
import '../../widgets/request_filters_bar.dart';
import '../../widgets/request_row.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(requestFiltersProvider);
    final notifier = ref.read(requestFiltersProvider.notifier);
    final requestsAsync = ref.watch(requestsListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(requestsListProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const PageHeader(
            title: 'Requests',
            subtitle: 'Every request submitted by employees, open or resolved',
          ),
          FolderCard(
            child: Column(
              children: [
                RequestFiltersBar(
                  search: filters.search,
                  onSearchChanged: (v) => notifier.state = filters.copyWith(search: v),
                  category: filters.category ?? '',
                  onCategoryChanged: (v) => notifier.state = RequestFilters(
                    category: v.isEmpty ? null : v,
                    status: filters.status,
                    search: filters.search,
                  ),
                  status: filters.status ?? '',
                  onStatusChanged: (v) => notifier.state = RequestFilters(
                    category: filters.category,
                    status: v.isEmpty ? null : v,
                    search: filters.search,
                  ),
                ),
                requestsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const ListMessage('No requests match these filters.');
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          RequestRow(item: items[i], showDivider: i < items.length - 1),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => ListMessage(
                    apiErrorMessage(e, fallback: "Couldn't load requests."),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
