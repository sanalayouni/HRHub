import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/decision_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';

class AiRecommendationCard extends StatelessWidget {
  final DecisionOut? decision;
  const AiRecommendationCard({super.key, this.decision});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Recommendation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (decision == null || decision!.aiRecommendation == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "This request hasn't been processed by an agent yet.",
                    style: TextStyle(color: AppColors.inkSoft),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            centerSpaceRadius: 28,
                            sectionsSpace: 0,
                            sections: [
                              PieChartSectionData(
                                value: (decision!.confidence ?? 0) * 100,
                                color: AppColors.accent,
                                radius: 10,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 100 - (decision!.confidence ?? 0) * 100,
                                color: AppColors.creamSoft,
                                radius: 10,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatConfidence(decision!.confidence),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Builder(builder: (context) {
                    final ai = normalizeAiRecommendation(decision!.aiRecommendation);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: ai.bg, borderRadius: BorderRadius.circular(999)),
                      child: Text(ai.label, style: TextStyle(color: ai.color, fontWeight: FontWeight.w700)),
                    );
                  }),
                ],
              ),
              if (decision!.decisionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REASONING',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.inkSoft, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(decision!.decisionReason!, style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
