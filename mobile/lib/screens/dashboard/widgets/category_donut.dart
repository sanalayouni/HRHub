import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/dashboard_summary_model.dart';
import '../../../theme/app_theme.dart';

class CategoryDonut extends StatelessWidget {
  final CategorySplit split;
  const CategoryDonut({super.key, required this.split});

  @override
  Widget build(BuildContext context) {
    final total = split.leave + split.salary + split.flexwork;
    final entries = [
      ('Leave', split.leave, AppColors.dustyBlue),
      ('Salary', split.salary, AppColors.accent),
      ('Flexible Work', split.flexwork, AppColors.sage),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requests by Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: entries
                          .where((e) => e.$2 > 0)
                          .map((e) => PieChartSectionData(
                                value: e.$2.toDouble(),
                                color: e.$3,
                                radius: 22,
                                showTitle: false,
                              ))
                          .toList(),
                      centerSpaceRadius: 45,
                      sectionsSpace: 3,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$total', style: Theme.of(context).textTheme.titleLarge),
                      const Text('total requests', style: TextStyle(fontSize: 10, color: AppColors.inkSoft)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: entries
                  .map((e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: e.$3, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text('${e.$1} ', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                          Text('${e.$2}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
