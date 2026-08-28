import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/employee_model.dart';
import '../../providers/employees_provider.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/form_controls.dart';

Future<void> showEmployeeFormSheet(BuildContext context, {EmployeeOut? employee}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: EmployeeFormSheet(employee: employee),
    ),
  );
}

class EmployeeFormSheet extends ConsumerStatefulWidget {
  final EmployeeOut? employee;
  const EmployeeFormSheet({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends ConsumerState<EmployeeFormSheet> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _jobTitle;
  late final TextEditingController _department;
  late final TextEditingController _managerName;
  late final TextEditingController _location;
  late final TextEditingController _salary;
  late final TextEditingController _leaveBalance;

  DateTime? _startDate;
  String _rating = '';
  bool _probationCompleted = false;
  bool _busy = false;
  String? _error;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _firstName = TextEditingController(text: e?.firstName ?? '');
    _lastName = TextEditingController(text: e?.lastName ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _jobTitle = TextEditingController(text: e?.jobTitle ?? '');
    _department = TextEditingController(text: e?.department ?? '');
    _managerName = TextEditingController(text: e?.managerName ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _salary = TextEditingController(text: e != null ? e.salary.toStringAsFixed(0) : '');
    _leaveBalance =
        TextEditingController(text: e?.annualLeaveBalance?.toString() ?? '');
    _startDate = e != null ? DateTime.tryParse(e.employmentStartDate) : null;
    _rating = e?.performanceRating ?? '';
    _probationCompleted = e?.probationCompleted ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _jobTitle,
      _department,
      _managerName,
      _location,
      _salary,
      _leaveBalance,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isValid =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _jobTitle.text.trim().isNotEmpty &&
      _department.text.trim().isNotEmpty &&
      _managerName.text.trim().isNotEmpty &&
      _location.text.trim().isNotEmpty &&
      _startDate != null &&
      (double.tryParse(_salary.text.trim()) ?? -1) >= 0;

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_isValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final leave = _leaveBalance.text.trim();
    final payload = <String, dynamic>{
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'email': _email.text.trim(),
      'department': _department.text.trim(),
      'job_title': _jobTitle.text.trim(),
      'manager_name': _managerName.text.trim(),
      'employment_start_date': _isoDate(_startDate!),
      'salary': double.parse(_salary.text.trim()),
      'location': _location.text.trim(),
      'probation_completed': _probationCompleted,
      'annual_leave_balance': leave.isEmpty ? null : int.tryParse(leave),
      'performance_rating': _rating.isEmpty ? null : _rating,
    };

    try {
      final actions = ref.read(employeeActionsProvider);
      if (_isEditing) {
        await actions.update(widget.employee!.employeeId, payload);
      } else {
        await actions.create(payload);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorMessage(
          error,
          fallback: "Couldn't ${_isEditing ? 'update' : 'add'} this employee. "
              'Check the fields and try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _isEditing ? 'Edit Employee' : 'Add Employee',
                    style: heading(size: 19, color: palette.ink),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: palette.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _Field(label: 'First Name', controller: _firstName, onChanged: _rebuild)),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(label: 'Last Name', controller: _lastName, onChanged: _rebuild)),
                ],
              ),
              _Field(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: _rebuild,
              ),
              Row(
                children: [
                  Expanded(child: _Field(label: 'Job Title', controller: _jobTitle, onChanged: _rebuild)),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(label: 'Department', controller: _department, onChanged: _rebuild)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _Field(label: 'Manager', controller: _managerName, onChanged: _rebuild)),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(label: 'Location', controller: _location, onChanged: _rebuild)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _Labelled(
                      label: 'Start Date',
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: palette.creamSoft),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startDate == null ? 'Select date' : _isoDate(_startDate!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _startDate == null ? palette.inkSoft : palette.ink,
                                  ),
                                ),
                              ),
                              Icon(Icons.calendar_today_rounded, size: 15, color: palette.inkSoft),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      label: 'Salary',
                      controller: _salary,
                      keyboardType: TextInputType.number,
                      onChanged: _rebuild,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: 'Leave Balance (days)',
                      controller: _leaveBalance,
                      keyboardType: TextInputType.number,
                      onChanged: _rebuild,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Labelled(
                      label: 'Performance Rating',
                      // The DB only accepts these five values, so this is a
                      // fixed list rather than free text.
                      child: FilterDropdown<String>(
                        value: _rating,
                        placeholder: 'Not rated',
                        options: {
                          '': 'Not rated',
                          for (final r in performanceRatings) r: r,
                        },
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _probationCompleted = !_probationCompleted),
                child: Row(
                  children: [
                    Checkbox(
                      value: _probationCompleted,
                      activeColor: palette.accent,
                      checkColor: palette.inkFixed,
                      onChanged: (v) => setState(() => _probationCompleted = v ?? false),
                    ),
                    Text(
                      'Probation completed',
                      style: TextStyle(fontSize: 14, color: palette.ink),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 12, color: palette.coral),
                ),
              ],
              const SizedBox(height: 16),
              AccentButton(
                label: _isEditing ? 'Save Changes' : 'Add Employee',
                busy: _busy,
                onPressed: _isValid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rebuild(String _) => setState(() {});
}

class _Labelled extends StatelessWidget {
  final String label;
  final Widget child;

  const _Labelled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.palette.inkSoft,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _Labelled(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: palette.ink),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: palette.creamSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: palette.creamSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: palette.accent, width: 2),
          ),
        ),
      ),
    );
  }
}
