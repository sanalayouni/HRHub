import uuid
from datetime import date, datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict

# Mirrors the employees_performance_rating_check constraint in Postgres.
PerformanceRating = Literal["Excellent", "Very Good", "Good", "Average", "Poor"]


class EmployeeListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    employee_id: uuid.UUID
    first_name: str
    last_name: str
    email: str
    job_title: str
    department: str
    employment_start_date: date
    location: str


class EmployeeCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    department: str
    job_title: str
    manager_name: str
    employment_start_date: date
    salary: float
    location: str
    probation_completed: Optional[bool] = None
    annual_leave_balance: Optional[int] = None
    performance_rating: Optional[PerformanceRating] = None


class EmployeeUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    department: Optional[str] = None
    job_title: Optional[str] = None
    manager_name: Optional[str] = None
    employment_start_date: Optional[date] = None
    salary: Optional[float] = None
    location: Optional[str] = None
    probation_completed: Optional[bool] = None
    annual_leave_balance: Optional[int] = None
    performance_rating: Optional[PerformanceRating] = None


class EmployeeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    employee_id: uuid.UUID
    first_name: str
    last_name: str
    email: str
    department: str
    job_title: str
    manager_name: str
    employment_start_date: date
    probation_completed: Optional[bool] = None
    salary: float
    annual_leave_balance: Optional[int] = None
    performance_rating: Optional[str] = None
    location: str
    tenure_years: float
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
