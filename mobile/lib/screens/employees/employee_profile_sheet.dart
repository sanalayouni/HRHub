import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../models/employee_model.dart';
import '../../providers/employees_provider.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/labels.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/status_badge.dart';
import 'employee_form_sheet.dart';

Future<void> showEmployeeProfileSheet(BuildContext context, String employeeId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => EmployeeProfileSheet(
        employeeId: employeeId,
        scrollController: scrollController,
      ),
    ),
  );
}

class EmployeeProfileSheet extends ConsumerStatefulWidget {
  final String employeeId;
  final ScrollController scrollController;

  const EmployeeProfileSheet({
    super.key,
    required this.employeeId,
    required this.scrollController,
  });

  @override
  ConsumerState<EmployeeProfileSheet> createState() => _EmployeeProfileSheetState();
}

class _EmployeeProfileSheetState extends ConsumerState<EmployeeProfileSheet> {
  bool _confirmingDelete = false;
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await ref.read(employeeActionsProvider).delete(widget.employeeId);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(error, fallback: "Couldn't delete this employee.")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final employeeAsync = ref.watch(employeeDetailProvider(widget.employeeId));

    return employeeAsync.when(
      loading: () => const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(apiErrorMessage(e, fallback: "Couldn't load this employee.")),
      ),
      data: (employee) => ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
          _Banner(employee: employee, onDelete: () {}),
          const SizedBox(height: 8),
          Center(
            child: Text(
              employee.fullName,
              style: heading(size: 21, color: palette.ink),
            ),
          ),
          Center(
            child: Text(
              employee.jobTitle,
              style: TextStyle(fontSize: 13, color: palette.inkSoft),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Basic Information'),
                _InfoRow(icon: Icons.mail_outline_rounded, label: 'E-Mail', value: employee.email),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Start Date',
                  value: formatDate(employee.employmentStartDate),
                ),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Manager',
                  value: employee.managerName,
                ),
                _InfoRow(
                  icon: Icons.apartment_rounded,
                  label: 'Department',
                  value: employee.department,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: employee.location,
                ),
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Probation',
                  value: (employee.probationCompleted ?? false) ? 'Completed' : 'In progress',
                ),
                const SizedBox(height: 22),
                _SectionTitle('Statistics'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.schedule_rounded,
                        tone: palette.dustyBlue,
                        label: 'Tenure',
                        value: '${employee.tenureYears} yrs',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.calendar_month_rounded,
                        tone: palette.sage,
                        label: 'Leave Balance',
                        value: employee.annualLeaveBalance != null
                            ? '${employee.annualLeaveBalance} days'
                            : '—',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.star_rounded,
                        tone: palette.accent,
                        label: 'Performance',
                        value: employee.performanceRating ?? '—',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.account_balance_wallet_outlined,
                        tone: palette.coral,
                        label: 'Salary',
                        value: formatSalary(employee.salary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle('Request History'),
                _RequestHistory(employeeId: widget.employeeId),
                const SizedBox(height: 20),
                Divider(color: palette.creamSoft),
                const SizedBox(height: 12),
                if (_confirmingDelete)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.coralSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Delete ${employee.fullName}? This can't be undone.",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: palette.ink,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _deleting
                              ? null
                              : () => setState(() => _confirmingDelete = false),
                          child: Text('Cancel', style: TextStyle(color: palette.inkSoft)),
                        ),
                        FilledButton(
                          onPressed: _deleting ? null : _delete,
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.coral,
                            foregroundColor: palette.inkFixed,
                          ),
                          child: Text(_deleting ? 'Deleting...' : 'Confirm'),
                        ),
                      ],
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => setState(() => _confirmingDelete = true),
                    icon: Icon(Icons.delete_outline_rounded, size: 16, color: palette.coral),
                    label: Text(
                      'Delete employee',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: palette.coral,
                      ),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends ConsumerWidget {
  final EmployeeOut employee;
  final VoidCallback onDelete;

  const _Banner({required this.employee, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return SizedBox(
      // Tall enough for the banner plus the avatar that overhangs it.
      height: 96 + 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 96,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF33353F), Color(0xFF565A6B), Color(0xFFF5C842)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: Row(
              children: [
                _BannerButton(
                  icon: Icons.edit_outlined,
                  onTap: () => showEmployeeFormSheet(context, employee: employee),
                ),
                const SizedBox(width: 8),
                _BannerButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Sits in front of the banner, overlapping its lower edge.
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.slate,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: palette.glassShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  initials(employee.fullName),
                  style: heading(size: 21, color: palette.cream),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BannerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: palette.inkSoft),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: heading(size: 14, weight: FontWeight.w600, color: context.palette.ink),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.creamSoft.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.slateSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: palette.slate),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, color: palette.inkSoft)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.tone,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 17, color: palette.inkFixed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: palette.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestHistory extends ConsumerWidget {
  final String employeeId;
  const _RequestHistory({required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final requestsAsync = ref.watch(employeeRequestsProvider(employeeId));

    return requestsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        apiErrorMessage(e, fallback: "Couldn't load this employee's requests."),
        style: TextStyle(fontSize: 13, color: palette.inkSoft),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Text(
            'No requests from this employee yet.',
            style: TextStyle(fontSize: 13, color: palette.inkSoft),
          );
        }
        return Column(
          children: [
            for (final req in requests)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: palette.cream,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/requests/${req.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CategoryBadge(category: req.requestType),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(req.createdAt),
                                  style: TextStyle(fontSize: 11, color: palette.inkSoft),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: req.status),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
