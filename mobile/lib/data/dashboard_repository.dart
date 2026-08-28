import '../core/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRepository {
  Future<DashboardSummary> fetchSummary() async {
    final response = await apiClient.get('/dashboard/summary');
    return DashboardSummary.fromJson(response.data);
  }
}
