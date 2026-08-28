import uuid

from sqlalchemy import Column, DateTime, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class Request(Base):
    __tablename__ = "requests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    request_type = Column(String, nullable=False)
    request_text = Column(Text, nullable=False)
    summary = Column(Text)
    gmail_message_id = Column(Text)
    gmail_thread_id = Column(Text)
    employee_email = Column(String)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

    decisions = relationship(
        "Decision",
        back_populates="request",
        order_by="Decision.created_at.desc()",
    )
