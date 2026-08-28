import 'package:flutter/material.dart';
import '../../../models/request_model.dart';
import '../../../theme/app_theme.dart';

class RequestContentCard extends StatelessWidget {
  final RequestDetail request;
  const RequestContentCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original Request', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (request.summary != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
                child: Text(request.summary!, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
              ),
              const SizedBox(height: 10),
            ],
            Text(request.requestText, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
