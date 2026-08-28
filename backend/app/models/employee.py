import uuid

from sqlalchemy import Boolean, Column, Date, DateTime, Integer, Numeric, String
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class Employee(Base):
    __tablename__ = "employees"

    employee_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    email = Column(String, nullable=False)
    department = Column(String, nullable=False)
    job_title = Column(String, nullable=False)
    manager_name = Column(String, nullable=False)
    employment_start_date = Column(Date, nullable=False)
    probation_completed = Column(Boolean)
    salary = Column(Numeric, nullable=False)
    annual_leave_balance = Column(Integer)
    performance_rating = Column(String)
    location = Column(String, nullable=False)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
