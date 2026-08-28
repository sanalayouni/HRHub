import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict


class DecisionStatus(str, Enum):
    """Matches the DB CHECK constraint on decisions.status exactly.
    There is no 'pending' value in the DB — a request with no decision
    row at all is treated as pending; 'needs_review' covers both an
    AI 'Request Info' recommendation and a not-yet-reviewed AI call."""

    needs_review = "needs_review"
    approved = "approved"
    rejected = "rejected"


class DecisionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    request_id: uuid.UUID
    status: str
    ai_recommendation: Optional[str] = None
    confidence: Optional[float] = None
    decision_reason: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class DecisionDecideIn(BaseModel):
    status: DecisionStatus
    notes: Optional[str] = None
