import '../core/api_client.dart';
import '../models/request_model.dart';

class DecisionsRepository {
  Future<List<RequestListItem>> fetchDecisions({
    String? category,
    String? status,
    String? search,
  }) async {
    final response = await apiClient.get(
      '/decisions',
      queryParameters: {
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return (response.data as List)
        .map((e) => RequestListItem.fromJson(e))
        .toList();
  }
}
