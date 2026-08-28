from typing import List, Optional

from pydantic import BaseModel


class CategorySplit(BaseModel):
    leave: int
    salary: int
    flexwork: int


class RecentDecisionItem(BaseModel):
    request_id: str
    employee_name: Optional[str] = None
    request_type: str
    status: str
    updated_at: str


class DashboardSummary(BaseModel):
    pending_count: int
    approved_this_week_count: int
    rejected_count: int
    total_employees: int
    category_split: CategorySplit
    recent_decisions: List[RecentDecisionItem]
