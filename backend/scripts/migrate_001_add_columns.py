"""
Additive migration: adds decisions.ai_recommendation, decisions.notes,
and requests.employee_email. Idempotent (IF NOT EXISTS), transactional.

Run from backend/ with the venv active:
    python scripts/migrate_001_add_columns.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import psycopg2

from app.core.config import settings

COLUMNS_TO_CHECK = {
    "decisions": ["ai_recommendation", "notes"],
    "requests": ["employee_email"],
}

MIGRATION_SQL = """
ALTER TABLE decisions ADD COLUMN IF NOT EXISTS ai_recommendation varchar;
ALTER TABLE decisions ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE requests  ADD COLUMN IF NOT EXISTS employee_email varchar;
"""


def print_columns(cur, label):
    print(f"\n--- {label} ---")
    for table, cols in COLUMNS_TO_CHECK.items():
        cur.execute(
            """
            select column_name, data_type
            from information_schema.columns
            where table_schema = 'public' and table_name = %s
            order by ordinal_position
            """,
            (table,),
        )
        present = {row[0]: row[1] for row in cur.fetchall()}
        for col in cols:
            status = present.get(col, "MISSING")
            print(f"  {table}.{col}: {status}")


def main():
    conn = psycopg2.connect(settings.database_url)
    try:
        with conn:
            with conn.cursor() as cur:
                print_columns(cur, "before")
                cur.execute(MIGRATION_SQL)
                print_columns(cur, "after")
        print("\nMigration committed successfully.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
