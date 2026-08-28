from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.decision import Decision
from app.models.request import Request as RequestModel
from app.schemas.request import RequestListItem
from app.services.lookups import find_employee_by_email, request_to_list_item

router = APIRouter(prefix="/api/v1/decisions", tags=["Decisions"])


@router.get("", response_model=list[RequestListItem])
def list_decisions(
    category: Optional[str] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    db: Session = Depends(get_db),
):
    """Audit log: one row per request that has at least one decision."""
    query = db.query(RequestModel).join(Decision, Decision.request_id == RequestModel.id)
    if category:
        query = query.filter(RequestModel.request_type == category)
    if date_from:
        query = query.filter(RequestModel.created_at >= date_from)
    if date_to:
        query = query.filter(RequestModel.created_at <= date_to)
    if search:
        like = f"%{search}%"
        query = query.filter(
            or_(
                RequestModel.request_text.ilike(like),
                RequestModel.summary.ilike(like),
                RequestModel.employee_email.ilike(like),
            )
        )

    reqs = (
        query.order_by(RequestModel.created_at.desc())
        .distinct()
        .offset(offset)
        .limit(limit)
        .all()
    )

    items = []
    for req in reqs:
        employee = find_employee_by_email(db, req.employee_email)
        decision = max(req.decisions, key=lambda d: d.created_at, default=None)
        item = request_to_list_item(req, employee, decision)
        if status and item.status != status:
            continue
        items.append(item)
    return items
