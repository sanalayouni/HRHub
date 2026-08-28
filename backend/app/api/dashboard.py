from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.decision import Decision
from app.models.employee import Employee
from app.models.request import Request as RequestModel
from app.schemas.dashboard import CategorySplit, DashboardSummary, RecentDecisionItem
from app.services.lookups import find_employee_by_email

router = APIRouter(prefix="/api/v1/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardSummary)
def dashboard_summary(db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    start_of_week = (now - timedelta(days=now.weekday())).replace(
        hour=0, minute=0, second=0, microsecond=0
    )

    
    total_requests = db.query(RequestModel.id).count()
    requests_with_decision = db.query(Decision.request_id).distinct().count()
    requests_never_processed = total_requests - requests_with_decision
    decisions_needs_review = (
        db.query(Decision).filter(Decision.status == "needs_review").count()
    )
    pending_count = requests_never_processed + decisions_needs_review

    approved_this_week_count = (
        db.query(Decision)
        .filter(Decision.status == "approved", Decision.updated_at >= start_of_week)
        .count()
    )
    rejected_count = db.query(Decision).filter(Decision.status == "rejected").count()
    total_employees = db.query(Employee).count()

    category_counts = dict(
        db.query(RequestModel.request_type, func.count(RequestModel.id))
        .group_by(RequestModel.request_type)
        .all()
    )
    category_split = CategorySplit(
        leave=category_counts.get("leave", 0),
        salary=category_counts.get("salary", 0),
        flexwork=category_counts.get("flexwork", 0),
    )

    recent = (
        db.query(Decision)
        .filter(Decision.status.in_(["approved", "rejected"]))
        .order_by(Decision.updated_at.desc())
        .limit(5)
        .all()
    )
    recent_decisions = []
    for decision in recent:
        req = db.query(RequestModel).filter(RequestModel.id == decision.request_id).first()
        if not req:
            continue
        employee = find_employee_by_email(db, req.employee_email)
        recent_decisions.append(
            RecentDecisionItem(
                request_id=str(req.id),
                employee_name=f"{employee.first_name} {employee.last_name}" if employee else None,
                request_type=req.request_type,
                status=decision.status,
                updated_at=decision.updated_at.isoformat(),
            )
        )

    return DashboardSummary(
        pending_count=pending_count,
        approved_this_week_count=approved_this_week_count,
        rejected_count=rejected_count,
        total_employees=total_employees,
        category_split=category_split,
        recent_decisions=recent_decisions,
    )
