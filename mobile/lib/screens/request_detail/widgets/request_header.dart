import 'package:flutter/material.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/form_controls.dart';
import '../../../widgets/status_badge.dart';

class RequestHeader extends StatelessWidget {
  final RequestDetail request;
  const RequestHeader({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final name = request.employee?.fullName ?? 'Unknown Employee';
    final status = request.decision?.status ?? 'pending';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Monogram(
              text: initials(name),
              size: 48,
              background: palette.ink,
              foreground: palette.cream,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: heading(size: 19, color: palette.ink)),
                  const SizedBox(height: 2),
                  Text(
                    '${request.employeeEmail ?? 'no email on file'} · '
                    '${formatDate(request.createdAt)}',
                    style: TextStyle(fontSize: 11, color: palette.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CategoryBadge(category: request.requestType),
            StatusBadge(status: status),
          ],
        ),
      ],
    );
  }
}
