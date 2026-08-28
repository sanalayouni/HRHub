import uuid
from datetime import date, datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.decision import Decision
from app.models.request import Request as RequestModel
from app.schemas.decision import DecisionDecideIn, DecisionOut
from app.schemas.request import RequestDetail, RequestListItem
from app.services.lookups import (
    find_employee_by_email,
    latest_decision,
    request_to_detail,
    request_to_list_item,
)

router = APIRouter(prefix="/api/v1/requests", tags=["Requests"])


@router.get("", response_model=list[RequestListItem])
def list_requests(
    category: Optional[str] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    db: Session = Depends(get_db),
):
    query = db.query(RequestModel)
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
        query.order_by(RequestModel.created_at.desc()).offset(offset).limit(limit).all()
    )

    items = []
    for req in reqs:
        employee = find_employee_by_email(db, req.employee_email)
        decision = latest_decision(db, req.id)
        item = request_to_list_item(req, employee, decision)
        if status and item.status != status:
            continue
        items.append(item)
    return items


@router.get("/{request_id}", response_model=RequestDetail)
def get_request(request_id: uuid.UUID, db: Session = Depends(get_db)):
    req = db.query(RequestModel).filter(RequestModel.id == request_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    employee = find_employee_by_email(db, req.employee_email)
    decision = latest_decision(db, req.id)
    return request_to_detail(req, employee, decision)


@router.delete("/{request_id}", status_code=204)
def delete_request(request_id: uuid.UUID, db: Session = Depends(get_db)):
    req = db.query(RequestModel).filter(RequestModel.id == request_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    db.query(Decision).filter(Decision.request_id == request_id).delete(synchronize_session=False)
    db.delete(req)
    db.commit()


@router.post("/{request_id}/decision", response_model=DecisionOut)
def decide_request(
    request_id: uuid.UUID, payload: DecisionDecideIn, db: Session = Depends(get_db)
):
    req = db.query(RequestModel).filter(RequestModel.id == request_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")

    decision = latest_decision(db, request_id)
    now = datetime.now(timezone.utc)

    if decision is None:
        decision = Decision(
            id=uuid.uuid4(),
            request_id=request_id,
            status=payload.status.value,
            notes=payload.notes,
            created_at=now,
            updated_at=now,
        )
        db.add(decision)
    else:
        decision.status = payload.status.value
        decision.notes = payload.notes
        decision.updated_at = now

    db.commit()
    db.refresh(decision)
    return DecisionOut.model_validate(decision)
