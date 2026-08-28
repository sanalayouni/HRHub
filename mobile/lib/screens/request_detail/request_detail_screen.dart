import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/requests_provider.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/labels.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/page_header.dart';
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
    final palette = context.palette;
    final requestAsync = ref.watch(requestDetailProvider(requestId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Request', style: heading(size: 17, color: palette.ink)),
      ),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListMessage(
          apiErrorMessage(e, fallback: "Couldn't load this request."),
        ),
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
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FINAL DECISION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: palette.inkSoft,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'This request was ${statusLabels[status]?.toLowerCase() ?? status}'
                                '${request.decision != null ? ' on ${formatDate(request.decision!.updatedAt)}' : ''}.',
                                style: TextStyle(fontSize: 13, color: palette.ink),
                              ),
                              if (request.decision?.notes != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '"${request.decision!.notes}"',
                                  style: TextStyle(fontSize: 13, color: palette.inkSoft),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isActionable)
                DecisionActionBar(
                  requestId: request.id,
                  existingNotes: request.decision?.notes,
                ),
            ],
          );
        },
      ),
    );
  }
}
