import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/decision_model.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/labels.dart';
import '../../../widgets/category_badge.dart';
import '../../../widgets/glass_card.dart';

class AiRecommendationCard extends StatelessWidget {
  final DecisionOut? decision;
  const AiRecommendationCard({super.key, this.decision});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GlassCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Recommendation', style: heading(size: 15, color: palette.ink)),
            const SizedBox(height: 12),
            if (decision == null || decision!.aiRecommendation == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "This request hasn't been processed by an agent yet.",
                    style: TextStyle(fontSize: 13, color: palette.inkSoft),
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
                                color: palette.accent,
                                radius: 10,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 100 - (decision!.confidence ?? 0) * 100,
                                color: palette.creamSoft,
                                radius: 10,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatConfidence(decision!.confidence),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: palette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Builder(builder: (context) {
                    final ai = normalizeAiRecommendation(palette, decision!.aiRecommendation);
                    return DotBadge(label: ai.label, color: ai.color);
                  }),
                ],
              ),
              if (decision!.decisionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REASONING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: palette.inkSoft,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        decision!.decisionReason!,
                        style: TextStyle(fontSize: 13, height: 1.4, color: palette.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ],
        ],
      ),
    );
  }
}
