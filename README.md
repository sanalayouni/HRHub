# HRHub

An HR request triage system. Employees email their leave, salary, or flexible-work
requests as they normally would; an n8n workflow reads the inbox, works out what each
one is asking for, checks it against the company policy and the employee's record, and
writes a recommendation to the database. HR reviews and decides in a dashboard —
**nothing is auto-approved.**

Every decision is stored with `status = needs_review`. The AI's opinion is kept
separately in `ai_recommendation`, alongside a confidence score and its reasoning, so a
human always makes the final call.

---

## How a request flows

```
Gmail inbox
    │
    ▼
Normalize Email ──► Summarize ──► Classify ──► Parse Category
                                                   │
                                                   ▼
                                            requests table  (row created in Supabase)
                                                   │
                                                   ▼
                                                 Merge ──► Router
                                                              │
                    ┌─────────────────────────────────────────┼──────────────────┐
                    ▼                                         ▼                  ▼
                  leave                                     salary            flexwork
                    │                                         │                  │
            Retrieve Policy  (pgvector similarity search over the policy PDFs)
                    │
             Build Prompt    (policy excerpts injected into the agent's message)
                    │
                  Agent      (+ employee-database tool)
                    │
            Parse Decision   (extract recommendation / confidence / reasoning)
                    │
                    ▼
             decisions table  (linked to the request, status = needs_review)
```

Anything that isn't an HR request is routed to a no-op and ignored.

### Why retrieval happens before the agent

The agents run on `llama3.2:3b`, which in practice calls **one tool per run** — measured
across real executions, each agent made exactly two LLM calls and never a third. When the
policy vector store was attached as a tool, the agent consulted it in only 3 of 7 runs,
regardless of what the system prompt demanded.

So policy retrieval was moved out of the agent's hands: a vector-store node runs
unconditionally in the main path and its results are folded into the prompt. The agent
keeps a single tool (the employee database). Policy is now guaranteed by construction,
and retrieval happens on every run.

---

## Repository layout

| Path | What it is |
|---|---|
| `Workflow/hrhub_fixed.json` | **The current n8n workflow.** Import this one. |
| `Workflow/v1.json` | Earlier export, kept for history — does not match what runs. |
| `Workflow/HRHub-v2-sanitized.json` | Sanitized export for sharing. |
| `backend/` | FastAPI service backing the dashboard. |
| `frontend/` | React + TypeScript + Vite web dashboard. |
| `mobile/` | Flutter app. |
| `scripts/` | Workflow patch scripts (see below). |

---

## Stack

- **Orchestration** — n8n (Docker), Gmail trigger, Supabase and Postgres nodes
- **Models** — Ollama, local: `llama3.2:3b` for chat, `nomic-embed-text` for embeddings
- **Data** — Supabase Postgres with pgvector for the policy documents
- **API** — FastAPI, SQLAlchemy, JWT auth
- **Web** — React, TanStack Query, React Router, Recharts, axios
- **Mobile** — Flutter

---

## Database

Two tables carry the workflow output. The constraints matter — the workflow writes to
them directly, so violating one silently kills an insert:

**`requests`**

| Column | Notes |
|---|---|
| `id` | uuid, generated |
| `request_type` | not null — `leave` / `salary` / `flexwork` / `not_hr` |
| `request_text` | not null |
| `summary`, `employee_email` | |
| `gmail_message_id` | **unique** — the same email cannot be processed twice |
| `gmail_thread_id`, `created_at`, `updated_at` | |

**`decisions`**

| Column | Notes |
|---|---|
| `id` | uuid, generated |
| `request_id` | **not null**, FK → `requests(id)` on delete cascade |
| `status` | **not null**, must be `approved` / `rejected` / `needs_review` |
| `confidence` | numeric, **must be between 0 and 1** (not a percentage) |
| `ai_recommendation` | the model's verdict, kept separate from `status` |
| `decision_reason`, `notes` | `notes` records why parsing failed, if it did |

Policy documents live in `leave_documents`, `salary_documents`, and
`flexwork_documents`, each with a matching `match_<name>` SQL function and 768-dimension
embeddings from `nomic-embed-text`.

---

## Running it

### Backend

```bash
cd backend
python -m venv .venv && .venv/Scripts/activate      # Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env                                 # then fill in the values
python run.py
```

Serves on `http://localhost:8000`. Health checks at `/api/v1/health` and
`/api/v1/health/db`; interactive docs at `/docs`.

`.env` is git-ignored and must never be committed. See `backend/.env.example` for the
four required variables and how to generate the secrets.

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Serves on `http://localhost:5173`, which is already in the backend's CORS allow-list.

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

### Workflow

Import `Workflow/hrhub_fixed.json` into n8n, then reconnect the credentials — exports
carry credential *names and ids only*, never the secrets:

- Gmail OAuth2 (trigger)
- Supabase API (requests, decisions, vector stores)
- Postgres (employee lookup tool)
- Ollama (chat + embeddings)
- Google Drive OAuth2 (policy PDF ingestion)

Ollama must be reachable from n8n. In Docker that is `http://host.docker.internal:11434`,
and both `llama3.2:3b` and `nomic-embed-text` need to be pulled.

The policy documents are ingested by the "Download file → Supabase Vector Store" branches.
**Run each one only once** — running twice duplicates every chunk, which wastes retrieval
slots on repeated text.

---

## Workflow scripts

The workflow is patched by script rather than by hand, so changes are reviewable and
repeatable. Each reads an exported workflow and writes a patched copy.

```bash
py scripts/fix_workflow.py           <in.json> <out.json> [workflow_id]
py scripts/add_deterministic_rag.py  <in.json> <out.json> [workflow_id]
```

- **`fix_workflow.py`** — populates `request_id` on the decision inserts, scales
  confidence to 0–1, forces a valid `status`, moves the requests insert into the main
  path, and normalizes the sender address.
- **`add_deterministic_rag.py`** — adds the always-on policy retrieval described above
  and unwires the vector store as an agent tool.

Each file's docstring explains what it changes and why.

### Two n8n gotchas worth knowing

- **Never use `$('Node').item` in a Code node here.** Paired-item resolution walks back
  through the Merge node and never returns inside n8n's task runner; the node is killed
  at the 300-second timeout and looks like a slow agent. Use `.all()` or `.first()`.
- A Code node that collapses many input items into one **must emit `pairedItem`**, or the
  agent's memory sub-node fails with *"Paired item data is unavailable."*

---

## Status

Working end to end: emails are classified, requests and decisions are stored, and policy
retrieval runs on every request.

Known rough edges:

- The employee-database tool is still called at the model's discretion — roughly 3 runs
  in 4. The same pre-fetch-and-inject pattern would make it deterministic.
- `llama3.2:3b` produces shallow reasoning and needs the output format restated at the
  end of the prompt to stay on format. `qwen3:8b` is the upgrade path if answer quality
  matters more than latency.
- Retrieval returns the top 3 chunks. A request hinging on a rule that doesn't rank in
  the top 3 won't have that rule in front of the agent.
