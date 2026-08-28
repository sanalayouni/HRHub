import 'package:flutter/material.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/status_badge.dart';

class RequestHeader extends StatelessWidget {
  final RequestDetail request;
  const RequestHeader({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final name = request.employee?.fullName ?? 'Unknown Employee';
    final status = request.decision?.status ?? 'pending';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.ink,
              child: Text(
                initials(name),
                style: const TextStyle(color: AppColors.cream, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${request.employeeEmail ?? 'no email on file'} · ${formatDate(request.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            CategoryBadge(category: request.requestType),
            const SizedBox(width: 8),
            StatusBadge(status: status),
          ],
        ),
      ],
    );
  }
}
