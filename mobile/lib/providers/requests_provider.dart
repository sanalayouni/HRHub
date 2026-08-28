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
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(decisionsProvider);
  }
}

final decisionActionsProvider = Provider((ref) => DecisionActions(ref));
