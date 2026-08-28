import uuid
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.employee import Employee
from app.models.request import Request as RequestModel
from app.schemas.employee import EmployeeCreate, EmployeeListItem, EmployeeOut, EmployeeUpdate
from app.schemas.request import RequestListItem
from app.services.lookups import employee_to_out, latest_decision, request_to_list_item

router = APIRouter(prefix="/api/v1/employees", tags=["Employees"])


@router.get("", response_model=list[EmployeeListItem])
def list_employees(
    search: Optional[str] = None,
    department: Optional[str] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    db: Session = Depends(get_db),
):
    query = db.query(Employee)
    if department:
        query = query.filter(Employee.department == department)
    if search:
        like = f"%{search}%"
        query = query.filter(
            or_(
                Employee.first_name.ilike(like),
                Employee.last_name.ilike(like),
                Employee.email.ilike(like),
            )
        )
    return (
        query.order_by(Employee.first_name).offset(offset).limit(limit).all()
    )


@router.post("", response_model=EmployeeOut, status_code=201)
def create_employee(payload: EmployeeCreate, db: Session = Depends(get_db)):
    now = datetime.utcnow()
    emp = Employee(**payload.model_dump(), created_at=now, updated_at=now)
    db.add(emp)
    db.commit()
    db.refresh(emp)
    return employee_to_out(emp)


@router.patch("/{employee_id}", response_model=EmployeeOut)
def update_employee(employee_id: uuid.UUID, payload: EmployeeUpdate, db: Session = Depends(get_db)):
    emp = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail="Employee not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(emp, field, value)
    emp.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(emp)
    return employee_to_out(emp)


@router.delete("/{employee_id}", status_code=204)
def delete_employee(employee_id: uuid.UUID, db: Session = Depends(get_db)):
    emp = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail="Employee not found")
    db.delete(emp)
    db.commit()


@router.get("/{employee_id}", response_model=EmployeeOut)
def get_employee(employee_id: uuid.UUID, db: Session = Depends(get_db)):
    emp = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail="Employee not found")
    return employee_to_out(emp)


@router.get("/{employee_id}/requests", response_model=list[RequestListItem])
def get_employee_requests(employee_id: uuid.UUID, db: Session = Depends(get_db)):
    emp = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail="Employee not found")

    reqs = (
        db.query(RequestModel)
        .filter(RequestModel.employee_email.ilike(emp.email))
        .order_by(RequestModel.created_at.desc())
        .all()
    )
    return [
        request_to_list_item(req, emp, latest_decision(db, req.id)) for req in reqs
    ]
