import 'decision_model.dart';
import 'employee_model.dart';

class RequestListItem {
  final String id;
  final String requestType;
  final String? employeeEmail;
  final String? employeeName;
  final String? summary;
  final String? aiRecommendation;
  final double? confidence;
  final String status; // pending | needs_review | approved | rejected
  final String createdAt;

  RequestListItem({
    required this.id,
    required this.requestType,
    required this.employeeEmail,
    required this.employeeName,
    required this.summary,
    required this.aiRecommendation,
    required this.confidence,
    required this.status,
    required this.createdAt,
  });

  factory RequestListItem.fromJson(Map<String, dynamic> json) {
    return RequestListItem(
      id: json['id'],
      requestType: json['request_type'],
      employeeEmail: json['employee_email'],
      employeeName: json['employee_name'],
      summary: json['summary'],
      aiRecommendation: json['ai_recommendation'],
      confidence: (json['confidence'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

class RequestDetail {
  final String id;
  final String requestType;
  final String requestText;
  final String? summary;
  final String? employeeEmail;
  final String createdAt;
  final String updatedAt;
  final EmployeeOut? employee;
  final DecisionOut? decision;

  RequestDetail({
    required this.id,
    required this.requestType,
    required this.requestText,
    required this.summary,
    required this.employeeEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.employee,
    required this.decision,
  });

  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    return RequestDetail(
      id: json['id'],
      requestType: json['request_type'],
      requestText: json['request_text'],
      summary: json['summary'],
      employeeEmail: json['employee_email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      employee: json['employee'] != null
          ? EmployeeOut.fromJson(json['employee'])
          : null,
      decision: json['decision'] != null
          ? DecisionOut.fromJson(json['decision'])
          : null,
    );
  }
}
