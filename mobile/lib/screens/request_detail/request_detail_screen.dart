import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/requests_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/decision_action_bar.dart';
import 'widgets/employee_context_card.dart';
import 'widgets/request_content_card.dart';
import 'widgets/request_header.dart';

class RequestDetailScreen extends ConsumerWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(requestDetailProvider(requestId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Request'),
      ),
      body: requestAsync.when(
        data: (request) {
          final status = request.decision?.status ?? 'pending';
          final isActionable = status == 'pending' || status == 'needs_review';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RequestHeader(request: request),
                      const SizedBox(height: 16),
                      RequestContentCard(request: request),
                      const SizedBox(height: 12),
                      EmployeeContextCard(employee: request.employee),
                      const SizedBox(height: 12),
                      AiRecommendationCard(decision: request.decision),
                      if (!isActionable) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FINAL DECISION',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.inkSoft, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'This request was $status on '
                                  '${request.decision != null ? DateFormat.yMd().format(DateTime.parse(request.decision!.updatedAt)) : ''}.',
                                ),
                                if (request.decision?.notes != null) ...[
                                  const SizedBox(height: 6),
                                  Text('"${request.decision!.notes}"', style: const TextStyle(color: AppColors.inkSoft)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isActionable)
                DecisionActionBar(requestId: request.id, existingNotes: request.decision?.notes),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Couldn't load this request: $e")),
      ),
    );
  }
}
