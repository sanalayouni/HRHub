import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.schemas.decision import DecisionOut
from app.schemas.employee import EmployeeOut


class RequestListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    request_type: str
    employee_email: Optional[str] = None
    employee_name: Optional[str] = None
    summary: Optional[str] = None
    ai_recommendation: Optional[str] = None
    confidence: Optional[float] = None
    status: str
    created_at: datetime


class RequestDetail(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    request_type: str
    request_text: str
    summary: Optional[str] = None
    employee_email: Optional[str] = None
    gmail_message_id: Optional[str] = None
    gmail_thread_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    employee: Optional[EmployeeOut] = None
    decision: Optional[DecisionOut] = None
