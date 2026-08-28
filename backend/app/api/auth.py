from fastapi import APIRouter, Depends, HTTPException, status

from app.core.config import settings
from app.core.security import create_access_token, get_current_user, verify_password
from app.schemas.auth import LoginIn, MeOut, TokenOut

router = APIRouter(prefix="/api/v1/auth", tags=["Auth"])


@router.post("/login", response_model=TokenOut)
def login(payload: LoginIn):
    email_ok = payload.email.strip().lower() == settings.hr_email.lower()
    password_ok = email_ok and verify_password(payload.password, settings.hr_password_hash)

    if not password_ok:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    return TokenOut(access_token=create_access_token(settings.hr_email))


@router.get("/me", response_model=MeOut)
def me(email: str = Depends(get_current_user)):
    return MeOut(email=email)
