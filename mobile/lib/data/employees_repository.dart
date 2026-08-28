import '../core/api_client.dart';
import '../models/employee_model.dart';
import '../models/request_model.dart';

class EmployeesRepository {
  Future<List<EmployeeListItem>> fetchEmployees({
    String? search,
    String? department,
  }) async {
    final response = await apiClient.get(
      '/employees',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (department != null && department.isNotEmpty) 'department': department,
      },
    );
    return (response.data as List).map((e) => EmployeeListItem.fromJson(e)).toList();
  }

  Future<EmployeeOut> fetchEmployee(String id) async {
    final response = await apiClient.get('/employees/$id');
    return EmployeeOut.fromJson(response.data);
  }

  Future<List<RequestListItem>> fetchEmployeeRequests(String id) async {
    final response = await apiClient.get('/employees/$id/requests');
    return (response.data as List).map((e) => RequestListItem.fromJson(e)).toList();
  }

  Future<EmployeeOut> createEmployee(Map<String, dynamic> payload) async {
    final response = await apiClient.post('/employees', data: payload);
    return EmployeeOut.fromJson(response.data);
  }

  Future<EmployeeOut> updateEmployee(String id, Map<String, dynamic> payload) async {
    final response = await apiClient.patch('/employees/$id', data: payload);
    return EmployeeOut.fromJson(response.data);
  }

  Future<void> deleteEmployee(String id) async {
    await apiClient.delete('/employees/$id');
  }
}
