import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/decisions_provider.dart';
import '../../../theme/app_theme.dart';

class DecisionFiltersBar extends ConsumerWidget {
  const DecisionFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(decisionFiltersProvider);
    final notifier = ref.read(decisionFiltersProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by employee or request...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.creamSoft),
            ),
          ),
          onChanged: (v) => notifier.state = filters.copyWith(search: v),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All categories',
                selected: filters.category == null,
                onTap: () => notifier.state = DecisionFilters(status: filters.status, search: filters.search),
              ),
              _FilterChip(
                label: 'Leave',
                selected: filters.category == 'leave',
                onTap: () => notifier.state = filters.copyWith(category: 'leave'),
              ),
              _FilterChip(
                label: 'Salary',
                selected: filters.category == 'salary',
                onTap: () => notifier.state = filters.copyWith(category: 'salary'),
              ),
              _FilterChip(
                label: 'Flexible Work',
                selected: filters.category == 'flexwork',
                onTap: () => notifier.state = filters.copyWith(category: 'flexwork'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All statuses',
                selected: filters.status == null,
                onTap: () => notifier.state = DecisionFilters(category: filters.category, search: filters.search),
              ),
              _FilterChip(
                label: 'Needs Review',
                selected: filters.status == 'needs_review',
                onTap: () => notifier.state = filters.copyWith(status: 'needs_review'),
              ),
              _FilterChip(
                label: 'Approved',
                selected: filters.status == 'approved',
                onTap: () => notifier.state = filters.copyWith(status: 'approved'),
              ),
              _FilterChip(
                label: 'Rejected',
                selected: filters.status == 'rejected',
                onTap: () => notifier.state = filters.copyWith(status: 'rejected'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.ink,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: selected ? AppColors.cream : AppColors.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.creamSoft),
        ),
      ),
    );
  }
}
