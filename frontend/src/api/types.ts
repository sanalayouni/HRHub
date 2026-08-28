export type RequestCategory = "leave" | "salary" | "flexwork";

// "pending" is a synthetic, API-only value meaning no decision row exists
// yet. The DB only ever stores needs_review / approved / rejected.
export type DecisionStatus = "pending" | "needs_review" | "approved" | "rejected";

// The DB enforces exactly these values via a check constraint on employees.
export type PerformanceRating = "Excellent" | "Very Good" | "Good" | "Average" | "Poor";

export const PERFORMANCE_RATINGS: PerformanceRating[] = [
  "Excellent",
  "Very Good",
  "Good",
  "Average",
  "Poor",
];

export interface RequestListItem {
  id: string;
  request_type: RequestCategory;
  employee_email: string | null;
  employee_name: string | null;
  summary: string | null;
  ai_recommendation: string | null;
  confidence: number | null;
  status: DecisionStatus;
  created_at: string;
}

export interface EmployeeOut {
  employee_id: string;
  first_name: string;
  last_name: string;
  email: string;
  department: string;
  job_title: string;
  manager_name: string;
  employment_start_date: string;
  probation_completed: boolean | null;
  salary: number;
  annual_leave_balance: number | null;
  performance_rating: PerformanceRating | null;
  location: string;
  tenure_years: number;
  created_at: string | null;
  updated_at: string | null;
}

export interface EmployeeCreate {
  first_name: string;
  last_name: string;
  email: string;
  department: string;
  job_title: string;
  manager_name: string;
  employment_start_date: string;
  salary: number;
  location: string;
  probation_completed?: boolean | null;
  annual_leave_balance?: number | null;
  performance_rating?: PerformanceRating | null;
}

export type EmployeeUpdate = Partial<EmployeeCreate>;

export interface EmployeeListItem {
  employee_id: string;
  first_name: string;
  last_name: string;
  email: string;
  job_title: string;
  department: string;
  employment_start_date: string;
  location: string;
}

export interface DecisionOut {
  id: string;
  request_id: string;
  status: "needs_review" | "approved" | "rejected";
  ai_recommendation: string | null;
  confidence: number | null;
  decision_reason: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface RequestDetail {
  id: string;
  request_type: RequestCategory;
  request_text: string;
  summary: string | null;
  employee_email: string | null;
  gmail_message_id: string | null;
  gmail_thread_id: string | null;
  created_at: string;
  updated_at: string;
  employee: EmployeeOut | null;
  decision: DecisionOut | null;
}

export interface DecisionDecideIn {
  status: "needs_review" | "approved" | "rejected";
  notes?: string | null;
}

export interface CategorySplit {
  leave: number;
  salary: number;
  flexwork: number;
}

export interface RecentDecisionItem {
  request_id: string;
  employee_name: string | null;
  request_type: RequestCategory;
  status: string;
  updated_at: string;
}

export interface DashboardSummary {
  pending_count: number;
  approved_this_week_count: number;
  rejected_count: number;
  total_employees: number;
  category_split: CategorySplit;
  recent_decisions: RecentDecisionItem[];
}

export interface RequestFilters {
  category?: RequestCategory;
  status?: DecisionStatus;
  search?: string;
  date_from?: string;
  date_to?: string;
}
