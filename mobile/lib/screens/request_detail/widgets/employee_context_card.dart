import 'package:flutter/material.dart';
import '../../../models/employee_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/glass_card.dart';

class EmployeeContextCard extends StatelessWidget {
  final EmployeeOut? employee;
  const EmployeeContextCard({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employee Data', style: heading(size: 15, color: palette.ink)),
          const SizedBox(height: 12),
          if (employee == null)
            Text(
              "No matching employee record found for this request's sender.",
              style: TextStyle(fontSize: 13, color: palette.inkSoft),
            )
          else
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _Field('Role', employee!.jobTitle),
                _Field('Department', employee!.department),
                _Field('Manager', employee!.managerName),
                _Field('Tenure', '${employee!.tenureYears} years'),
                _Field(
                  'Probation',
                  employee!.probationCompleted == true ? 'Completed' : 'In progress',
                ),
                _Field(
                  'Leave Balance',
                  employee!.annualLeaveBalance != null
                      ? '${employee!.annualLeaveBalance} days'
                      : '—',
                ),
                _Field('Performance', employee!.performanceRating ?? '—'),
                _Field('Salary', formatSalary(employee!.salary)),
                _Field('Location', employee!.location),
              ],
            ),
        ],
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
    final palette = context.palette;
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: palette.inkSoft)),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}
