import 'package:flutter/material.dart';
import '../../../models/employee_model.dart';
import '../../../theme/app_theme.dart';

class EmployeeContextCard extends StatelessWidget {
  final EmployeeOut? employee;
  const EmployeeContextCard({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Data', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (employee == null)
              const Text(
                "No matching employee record found for this request's sender.",
                style: TextStyle(color: AppColors.inkSoft),
              )
            else
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _Field('Role', employee!.jobTitle),
                  _Field('Department', employee!.department),
                  _Field('Manager', employee!.managerName),
                  _Field('Tenure', '${employee!.tenureYears} years'),
                  _Field('Probation', employee!.probationCompleted == true ? 'Completed' : 'In progress'),
                  _Field(
                    'Leave Balance',
                    employee!.annualLeaveBalance != null ? '${employee!.annualLeaveBalance} days' : '—',
                  ),
                  _Field('Performance', employee!.performanceRating ?? '—'),
                  _Field('Location', employee!.location),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
