from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.auth import router as auth_router
from app.api.dashboard import router as dashboard_router
from app.api.decisions import router as decisions_router
from app.api.employees import router as employees_router
from app.api.requests import router as requests_router
from app.core.database import get_db
from app.core.security import get_current_user


app = FastAPI(
    title="RHub API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5175",
        "http://127.0.0.1:5175",
        "http://localhost:5080",
        "http://127.0.0.1:5080",
        "http://192.168.0.164:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "RHub API is running"
    }


@app.get("/api/v1/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.get("/api/v1/health/db")
def db_health_check(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT 1"))
    return {
        "database": "connected",
        "result": result.scalar(),
    }


app.include_router(auth_router)
app.include_router(requests_router, dependencies=[Depends(get_current_user)])
app.include_router(decisions_router, dependencies=[Depends(get_current_user)])
app.include_router(employees_router, dependencies=[Depends(get_current_user)])
app.include_router(dashboard_router, dependencies=[Depends(get_current_user)])