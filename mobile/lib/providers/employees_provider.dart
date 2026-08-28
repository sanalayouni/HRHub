import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/employees_repository.dart';
import '../models/employee_model.dart';
import '../models/request_model.dart';

final employeesRepositoryProvider = Provider((ref) => EmployeesRepository());

class EmployeeFilters {
  final String search;
  final String department;

  const EmployeeFilters({this.search = '', this.department = ''});

  EmployeeFilters copyWith({String? search, String? department}) {
    return EmployeeFilters(
      search: search ?? this.search,
      department: department ?? this.department,
    );
  }
}

final employeeFiltersProvider = StateProvider((ref) => const EmployeeFilters());

final employeesProvider = FutureProvider<List<EmployeeListItem>>((ref) {
  final filters = ref.watch(employeeFiltersProvider);
  return ref.watch(employeesRepositoryProvider).fetchEmployees(
        search: filters.search,
        department: filters.department,
      );
});

/// Department list for the filter dropdown, derived from the unfiltered set so
/// the options don't disappear as you narrow the list — same as the web page.
final departmentsProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(employeesRepositoryProvider).fetchEmployees();
  final names = all.map((e) => e.department).toSet().toList()..sort();
  return names;
});

final employeeDetailProvider =
    FutureProvider.family<EmployeeOut, String>((ref, id) {
  return ref.watch(employeesRepositoryProvider).fetchEmployee(id);
});

final employeeRequestsProvider =
    FutureProvider.family<List<RequestListItem>, String>((ref, id) {
  return ref.watch(employeesRepositoryProvider).fetchEmployeeRequests(id);
});

/// The five values the DB's check constraint accepts.
const performanceRatings = ['Excellent', 'Very Good', 'Good', 'Average', 'Poor'];

class EmployeeActions {
  final Ref ref;
  EmployeeActions(this.ref);

  void _refresh() {
    ref.invalidate(employeesProvider);
    ref.invalidate(departmentsProvider);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    await ref.read(employeesRepositoryProvider).createEmployee(payload);
    _refresh();
  }

  Future<void> update(String id, Map<String, dynamic> payload) async {
    await ref.read(employeesRepositoryProvider).updateEmployee(id, payload);
    ref.invalidate(employeeDetailProvider(id));
    _refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(employeesRepositoryProvider).deleteEmployee(id);
    _refresh();
  }
}

final employeeActionsProvider = Provider((ref) => EmployeeActions(ref));
