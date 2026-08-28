"""
Set the HR login password by rewriting HR_PASSWORD_HASH in backend/.env.

Prompts twice (input is hidden), hashes with bcrypt, and replaces only that
one line. The plaintext is never printed, logged, or stored.

Run from backend/ with the venv active:
    .venv/Scripts/python.exe scripts/set_hr_password.py
"""
import getpass
import sys
from pathlib import Path

import bcrypt

ENV_PATH = Path(__file__).resolve().parent.parent / ".env"
KEY = "HR_PASSWORD_HASH"


def main() -> int:
    if not ENV_PATH.exists():
        print(f"No .env found at {ENV_PATH}")
        return 1

    password = getpass.getpass("New HR password: ")
    if not password:
        print("Aborted: empty password.")
        return 1
    if password != getpass.getpass("Confirm password: "):
        print("Aborted: the two entries didn't match.")
        return 1

    new_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    lines = ENV_PATH.read_text(encoding="utf-8").splitlines(keepends=True)
    replaced = False
    for i, line in enumerate(lines):
        if line.split("=", 1)[0].strip().upper() == KEY:
            ending = "\n" if line.endswith("\n") else ""
            lines[i] = f"{KEY}={new_hash}{ending}"
            replaced = True
            break
    if not replaced:
        if lines and not lines[-1].endswith("\n"):
            lines[-1] += "\n"
        lines.append(f"{KEY}={new_hash}\n")

    ENV_PATH.write_text("".join(lines), encoding="utf-8")

    # Prove the stored hash accepts the password that was just typed.
    stored = next(
        l.split("=", 1)[1].strip()
        for l in ENV_PATH.read_text(encoding="utf-8").splitlines()
        if l.split("=", 1)[0].strip().upper() == KEY
    )
    ok = bcrypt.checkpw(password.encode(), stored.encode())
    print(f"{KEY} updated. Verification: {'MATCH' if ok else 'FAILED'}")
    print("Restart the backend (uvicorn --reload picks up code, not .env).")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
