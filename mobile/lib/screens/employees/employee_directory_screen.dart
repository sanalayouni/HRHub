import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/employee_model.dart';
import '../../providers/employees_provider.dart';
import '../../theme/app_palette.dart';
import '../../theme/labels.dart';
import '../../widgets/folder_card.dart';
import '../../widgets/form_controls.dart';
import '../../widgets/page_header.dart';
import 'employee_form_sheet.dart';
import 'employee_profile_sheet.dart';

class EmployeeDirectoryScreen extends ConsumerWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final filters = ref.watch(employeeFiltersProvider);
    final notifier = ref.read(employeeFiltersProvider.notifier);
    final employeesAsync = ref.watch(employeesProvider);
    final departments = ref.watch(departmentsProvider).valueOrNull ?? const <String>[];

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(employeesProvider);
        ref.invalidate(departmentsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          PageHeader(
            title: 'Employees',
            subtitle: 'Browse employee records referenced by the AI agents',
            action: Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => showEmployeeFormSheet(context),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.add_rounded, color: palette.inkFixed),
                ),
              ),
            ),
          ),
          FolderCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      SearchField(
                        value: filters.search,
                        hint: 'Search employees...',
                        onChanged: (v) => notifier.state = filters.copyWith(search: v),
                      ),
                      const SizedBox(height: 10),
                      FilterDropdown<String>(
                        value: filters.department,
                        placeholder: 'All departments',
                        options: {
                          '': 'All departments',
                          for (final d in departments) d: d,
                        },
                        onChanged: (v) => notifier.state = filters.copyWith(department: v),
                      ),
                    ],
                  ),
                ),
                employeesAsync.when(
                  data: (employees) {
                    if (employees.isEmpty) {
                      return const ListMessage('No employees match these filters.');
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < employees.length; i++)
                          _EmployeeRow(
                            employee: employees[i],
                            showDivider: i < employees.length - 1,
                          ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => ListMessage(
                    apiErrorMessage(e, fallback: "Couldn't load employees."),
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

class _EmployeeRow extends StatelessWidget {
  final EmployeeListItem employee;
  final bool showDivider;

  const _EmployeeRow({required this.employee, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => showEmployeeProfileSheet(context, employee.employeeId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: showDivider ? palette.creamSoft : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            Monogram(text: initials(employee.fullName), size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${employee.jobTitle} · ${employee.department}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: palette.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  employee.location,
                  style: TextStyle(fontSize: 12, color: palette.inkSoft),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(employee.employmentStartDate),
                  style: TextStyle(fontSize: 11, color: palette.inkSoft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
