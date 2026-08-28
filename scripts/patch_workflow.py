"""
Patches the HRHub n8n workflow (g.json) so that:
  1. employee_email gets populated on the requests table insert.
  2. Normalize Email's email_from expression extracts + lowercases the
     bare address instead of the raw "Name <addr>" header.
  3. The Structured Output Parser is wired to all three agents.
  4. salary/flexible work agent branches feed the decisions insert node.
  5. The decisions insert node's field mapping is filled in correctly,
     using status="needs_review" at insert time (never the AI's raw
     recommendation - that stays separate in ai_recommendation).

Run once: python scripts/patch_workflow.py
Reads from  C:\\Users\\sanal\\Downloads\\g.json
Writes to   Workflow/hrhub_patched.json
"""
import json
from pathlib import Path

SRC = Path(r"C:\Users\sanal\Downloads\g.json")
DST = Path(__file__).resolve().parent.parent / "Workflow" / "hrhub_patched.json"

with open(SRC, "r", encoding="utf-8") as f:
    wf = json.load(f)

nodes_by_name = {n["name"]: n for n in wf["nodes"]}
connections = wf["connections"]

# 1. Add employee_email to the "request table" insert node.
request_table = nodes_by_name["request table"]
request_table["parameters"]["fieldsUi"]["fieldValues"].append(
    {
        "fieldId": "employee_email",
        "fieldValue": "={{ $('Normalize Email').item.json.email_from }}",
    }
)

# 2. Harden Normalize Email's email_from expression.
normalize_email = nodes_by_name["Normalize Email"]
for assignment in normalize_email["parameters"]["assignments"]["assignments"]:
    if assignment["name"] == "email_from":
        assignment["value"] = (
            "={{ ($json.From.match(/<(.*)>/) ? $json.From.match(/<(.*)>/)[1] "
            ": $json.From).toLowerCase().trim() }}"
        )

# 3. Wire Structured Output Parser to all three agents.
connections["Structured Output Parser"] = {
    "ai_outputParser": [
        [
            {"node": "leave request agent", "type": "ai_outputParser", "index": 0},
            {"node": "salary request agent", "type": "ai_outputParser", "index": 0},
            {"node": "flexible work agent", "type": "ai_outputParser", "index": 0},
        ]
    ]
}

# 4. Wire salary/flexwork agent main outputs into "desicions table".
connections["salary request agent"] = {
    "main": [[{"node": "desicions table", "type": "main", "index": 0}]]
}
connections["flexible work agent"] = {
    "main": [[{"node": "desicions table", "type": "main", "index": 0}]]
}

# 5. Fix the "desicions table" insert node's field mapping.
desicions_table = nodes_by_name["desicions table"]
desicions_table["parameters"]["fieldsUi"]["fieldValues"] = [
    {"fieldId": "request_id", "fieldValue": "={{ $('request table').item.json.id }}"},
    {"fieldId": "status", "fieldValue": "needs_review"},
    {"fieldId": "confidence", "fieldValue": "={{ $json.output.confidence }}"},
    {"fieldId": "decision_reason", "fieldValue": "={{ $json.output.reasoning }}"},
    {"fieldId": "ai_recommendation", "fieldValue": "={{ $json.output.recommendation }}"},
]

DST.parent.mkdir(parents=True, exist_ok=True)
with open(DST, "w", encoding="utf-8") as f:
    json.dump(wf, f, indent=2, ensure_ascii=False)

print(f"Patched workflow written to {DST}")
