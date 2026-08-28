class EmployeeOut {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final String jobTitle;
  final String managerName;
  final String employmentStartDate;
  final bool? probationCompleted;
  final double salary;
  final int? annualLeaveBalance;
  final String? performanceRating;
  final String location;
  final double tenureYears;

  EmployeeOut({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.managerName,
    required this.employmentStartDate,
    required this.probationCompleted,
    required this.salary,
    required this.annualLeaveBalance,
    required this.performanceRating,
    required this.location,
    required this.tenureYears,
  });

  String get fullName => "$firstName $lastName";

  factory EmployeeOut.fromJson(Map<String, dynamic> json) {
    return EmployeeOut(
      employeeId: json['employee_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      department: json['department'],
      jobTitle: json['job_title'],
      managerName: json['manager_name'],
      employmentStartDate: json['employment_start_date'],
      probationCompleted: json['probation_completed'],
      salary: (json['salary'] as num).toDouble(),
      annualLeaveBalance: json['annual_leave_balance'],
      performanceRating: json['performance_rating'],
      location: json['location'],
      tenureYears: (json['tenure_years'] as num).toDouble(),
    );
  }
}
