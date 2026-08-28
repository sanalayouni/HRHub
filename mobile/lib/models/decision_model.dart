class DecisionOut {
  final String id;
  final String requestId;
  final String status; // needs_review | approved | rejected
  final String? aiRecommendation;
  final double? confidence;
  final String? decisionReason;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  DecisionOut({
    required this.id,
    required this.requestId,
    required this.status,
    required this.aiRecommendation,
    required this.confidence,
    required this.decisionReason,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DecisionOut.fromJson(Map<String, dynamic> json) {
    return DecisionOut(
      id: json['id'],
      requestId: json['request_id'],
      status: json['status'],
      aiRecommendation: json['ai_recommendation'],
      confidence: (json['confidence'] as num?)?.toDouble(),
      decisionReason: json['decision_reason'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
