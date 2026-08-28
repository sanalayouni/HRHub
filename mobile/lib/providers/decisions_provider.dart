import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/decisions_repository.dart';
import '../models/request_model.dart';

final decisionsRepositoryProvider = Provider((ref) => DecisionsRepository());

class DecisionFilters {
  final String? category;
  final String? status;
  final String search;

  const DecisionFilters({this.category, this.status, this.search = ''});

  DecisionFilters copyWith({String? category, String? status, String? search}) {
    return DecisionFilters(
      category: category ?? this.category,
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }
}

final decisionFiltersProvider = StateProvider((ref) => const DecisionFilters());

final decisionsProvider = FutureProvider<List<RequestListItem>>((ref) {
  final filters = ref.watch(decisionFiltersProvider);
  return ref.watch(decisionsRepositoryProvider).fetchDecisions(
        category: filters.category,
        status: filters.status,
        search: filters.search,
      );
});
