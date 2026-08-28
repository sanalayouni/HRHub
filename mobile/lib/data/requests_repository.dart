import '../core/api_client.dart';
import '../models/request_model.dart';
import '../models/decision_model.dart';

class RequestsRepository {
  Future<List<RequestListItem>> fetchRequests({
    String? category,
    String? status,
    String? search,
  }) async {
    final response = await apiClient.get(
      '/requests',
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

  Future<RequestDetail> fetchRequest(String id) async {
    final response = await apiClient.get('/requests/$id');
    return RequestDetail.fromJson(response.data);
  }

  Future<DecisionOut> decideRequest(String id, String status, String? notes) async {
    final response = await apiClient.post(
      '/requests/$id/decision',
      data: {'status': status, 'notes': notes},
    );
    return DecisionOut.fromJson(response.data);
  }
}
