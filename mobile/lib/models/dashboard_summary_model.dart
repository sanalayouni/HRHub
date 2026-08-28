class CategorySplit {
  final int leave;
  final int salary;
  final int flexwork;

  CategorySplit({required this.leave, required this.salary, required this.flexwork});

  factory CategorySplit.fromJson(Map<String, dynamic> json) {
    return CategorySplit(
      leave: json['leave'],
      salary: json['salary'],
      flexwork: json['flexwork'],
    );
  }
}

class RecentDecisionItem {
  final String requestId;
  final String? employeeName;
  final String requestType;
  final String status;
  final String updatedAt;

  RecentDecisionItem({
    required this.requestId,
    required this.employeeName,
    required this.requestType,
    required this.status,
    required this.updatedAt,
  });

  factory RecentDecisionItem.fromJson(Map<String, dynamic> json) {
    return RecentDecisionItem(
      requestId: json['request_id'],
      employeeName: json['employee_name'],
      requestType: json['request_type'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }
}

class DashboardSummary {
  final int pendingCount;
  final int approvedThisWeekCount;
  final int rejectedCount;
  final int totalEmployees;
  final CategorySplit categorySplit;
  final List<RecentDecisionItem> recentDecisions;

  DashboardSummary({
    required this.pendingCount,
    required this.approvedThisWeekCount,
    required this.rejectedCount,
    required this.totalEmployees,
    required this.categorySplit,
    required this.recentDecisions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      pendingCount: json['pending_count'],
      approvedThisWeekCount: json['approved_this_week_count'],
      rejectedCount: json['rejected_count'],
      totalEmployees: json['total_employees'],
      categorySplit: CategorySplit.fromJson(json['category_split']),
      recentDecisions: (json['recent_decisions'] as List)
          .map((e) => RecentDecisionItem.fromJson(e))
          .toList(),
    );
  }
}
