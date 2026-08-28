import 'package:flutter/material.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_card.dart';

class RequestContentCard extends StatelessWidget {
  final RequestDetail request;
  const RequestContentCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original Request', style: heading(size: 15, color: palette.ink)),
          const SizedBox(height: 10),
          if (request.summary != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                request.summary!,
                style: TextStyle(fontSize: 13, color: palette.inkSoft, height: 1.4),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            request.requestText,
            style: TextStyle(fontSize: 13, height: 1.5, color: palette.ink),
          ),
        ],
      ),
    );
  }
}
