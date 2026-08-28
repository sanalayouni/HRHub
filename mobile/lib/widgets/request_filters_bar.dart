import 'package:flutter/material.dart';
import 'form_controls.dart';

/// Search + category + status filters, matching the web `RequestsFilters` and
/// `DecisionFilters` bars.
class RequestFiltersBar extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearchChanged;
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final String status;
  final ValueChanged<String> onStatusChanged;

  const RequestFiltersBar({
    super.key,
    required this.search,
    required this.onSearchChanged,
    required this.category,
    required this.onCategoryChanged,
    required this.status,
    required this.onStatusChanged,
  });

  static const _categories = {
    '': 'All categories',
    'leave': 'Leave',
    'salary': 'Salary',
    'flexwork': 'Flexible Work',
  };

  static const _statuses = {
    '': 'All statuses',
    'needs_review': 'Needs Review',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          SearchField(
            value: search,
            hint: 'Search by employee or request...',
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilterDropdown<String>(
                  value: category,
                  placeholder: 'All categories',
                  options: _categories,
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilterDropdown<String>(
                  value: status,
                  placeholder: 'All statuses',
                  options: _statuses,
                  onChanged: onStatusChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
