from datetime import date
from typing import Optional

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.decision import Decision
from app.models.employee import Employee
from app.models.request import Request
from app.schemas.decision import DecisionOut
from app.schemas.employee import EmployeeOut
from app.schemas.request import RequestDetail, RequestListItem


def find_employee_by_email(db: Session, email: Optional[str]) -> Optional[Employee]:
    if not email:
        return None
    return (
        db.query(Employee)
        .filter(func.lower(Employee.email) == email.lower().strip())
        .first()
    )


def latest_decision(db: Session, request_id) -> Optional[Decision]:
    return (
        db.query(Decision)
        .filter(Decision.request_id == request_id)
        .order_by(Decision.created_at.desc())
        .first()
    )


def tenure_years(start_date: date) -> float:
    days = (date.today() - start_date).days
    return round(days / 365.25, 1)


def employee_to_out(emp: Employee) -> EmployeeOut:
    return EmployeeOut(
        employee_id=emp.employee_id,
        first_name=emp.first_name,
        last_name=emp.last_name,
        email=emp.email,
        department=emp.department,
        job_title=emp.job_title,
        manager_name=emp.manager_name,
        employment_start_date=emp.employment_start_date,
        probation_completed=emp.probation_completed,
        salary=float(emp.salary),
        annual_leave_balance=emp.annual_leave_balance,
        performance_rating=emp.performance_rating,
        location=emp.location,
        tenure_years=tenure_years(emp.employment_start_date),
        created_at=emp.created_at,
        updated_at=emp.updated_at,
    )


def request_to_list_item(
    req: Request, employee: Optional[Employee], decision: Optional[Decision]
) -> RequestListItem:
    return RequestListItem(
        id=req.id,
        request_type=req.request_type,
        employee_email=req.employee_email,
        employee_name=f"{employee.first_name} {employee.last_name}" if employee else None,
        summary=req.summary,
        ai_recommendation=decision.ai_recommendation if decision else None,
        confidence=float(decision.confidence) if decision and decision.confidence is not None else None,
        # "pending" here is a synthetic API-only value: no decision row
        # exists yet, so nothing has been written to the DB.
        status=decision.status if decision else "pending",
        created_at=req.created_at,
    )


def request_to_detail(
    req: Request, employee: Optional[Employee], decision: Optional[Decision]
) -> RequestDetail:
    return RequestDetail(
        id=req.id,
        request_type=req.request_type,
        request_text=req.request_text,
        summary=req.summary,
        employee_email=req.employee_email,
        gmail_message_id=req.gmail_message_id,
        gmail_thread_id=req.gmail_thread_id,
        created_at=req.created_at,
        updated_at=req.updated_at,
        employee=employee_to_out(employee) if employee else None,
        decision=DecisionOut.model_validate(decision) if decision else None,
    )
