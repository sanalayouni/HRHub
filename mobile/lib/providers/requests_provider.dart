import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/requests_repository.dart';
import '../models/request_model.dart';
import 'dashboard_provider.dart';
import 'decisions_provider.dart';

final requestsRepositoryProvider = Provider((ref) => RequestsRepository());

final pendingRequestsProvider = FutureProvider<List<RequestListItem>>((ref) async {
  final all = await ref.watch(requestsRepositoryProvider).fetchRequests();
  return all
      .where((r) => r.status == 'pending' || r.status == 'needs_review')
      .toList();
});

class RequestFilters {
  final String? category;
  final String? status;
  final String search;

  const RequestFilters({this.category, this.status, this.search = ''});

  RequestFilters copyWith({String? category, String? status, String? search}) {
    return RequestFilters(
      category: category ?? this.category,
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }
}

final requestFiltersProvider = StateProvider((ref) => const RequestFilters());

/// Every request, open or resolved — the web `Requests` page.
final requestsListProvider = FutureProvider<List<RequestListItem>>((ref) {
  final filters = ref.watch(requestFiltersProvider);
  return ref.watch(requestsRepositoryProvider).fetchRequests(
        category: filters.category,
        status: filters.status,
        search: filters.search,
      );
});

final requestDetailProvider =
    FutureProvider.family<RequestDetail, String>((ref, id) {
  return ref.watch(requestsRepositoryProvider).fetchRequest(id);
});

class DecisionActions {
  final Ref ref;
  DecisionActions(this.ref);

  Future<void> decide(String requestId, String status, String? notes) async {
    await ref.read(requestsRepositoryProvider).decideRequest(requestId, status, notes);
    ref.invalidate(requestDetailProvider(requestId));
    ref.invalidate(pendingRequestsProvider);
    ref.invalidate(requestsListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(decisionsProvider);
  }
}

final decisionActionsProvider = Provider((ref) => DecisionActions(ref));
