"""
Fixes the HRHub n8n workflow so that rows actually land in Supabase.

Diagnosis (verified against the live Supabase schema on 2026-08-27):

  requests.request_type   NOT NULL
  decisions.request_id    NOT NULL  REFERENCES requests(id)
  decisions.status        CHECK IN ('approved','rejected','needs_review')
  decisions.confidence    CHECK (confidence >= 0 AND confidence <= 1)

Bugs found in the live "Rag" workflow (id 1GFdRw91V2vMHh6E):

  1. request_id was never populated on any decisions insert.
     - "desicions table" had a request_id field with no value at all.
     - "Create a row" / "Create a row1" had no request_id field.
     - The Code nodes read `$json.request_id`, but at that point $json is the
       agent output ({output: "..."}), which has no request_id. Always undefined.
     => NOT NULL + FK violation. Every decisions insert failed.

  2. confidence was parsed as a percentage (0-100) but the CHECK constraint
     requires 0-1. "Confidence: 92%" -> 92 -> violates the constraint.
     => insert failed whenever a confidence was parsed at all.

  3. "Code in JavaScript2" and "Code in JavaScript3" (the flexwork and salary
     branches) set status = "Pending", which is not in the allowed set.
     => every salary / flexwork decision insert failed.

  4. request_id could not be referenced at all from the decision branches:
     "request table" sat on a sibling branch off "Parse Category", so it was
     not an ancestor of the Code nodes and `$('request table').item` cannot
     resolve a paired item across sibling branches.
     => fixed by moving "request table" into the main line:
        Parse Category -> request table -> Merge[input 1]
        and switching the router to read request_type (same values as
        category) off the inserted row.

  5. Normalize Email stored the raw "Name <addr>" From header in
     employee_email instead of the bare lowercased address, so rows could not
     be joined back to employees.

  6. The agent-output parser only matched one rigid text format, so
     ai_recommendation came back NULL even on the one decision that inserted.
     Replaced with a parser that accepts structured JSON, a JSON string, or
     the "Recommendation:/Confidence:/Reasoning:" text form.

status is deliberately always written as 'needs_review': the AI's own call is
kept separately in ai_recommendation, and HR stays in the loop.

Usage:
    py scripts/fix_workflow.py <input.json> <output.json>
"""

import json
import sys
import uuid
from pathlib import Path

NEW_NAME = "Rag - Fixed (storage)"

# Shared parser for the three agent branches. Tolerates structured output,
# a JSON string, or the plain-text "Recommendation:/Confidence:/Reasoning:" form.
DECISION_PARSER_JS = r"""
// Normalise whatever the agent produced into a decisions-table row.
const out = $json.output;

let recommendation = null;
let confidence = null;
let reasoning = null;

function fromObject(o) {
  if (!o || typeof o !== 'object') return false;
  if (o.recommendation !== undefined) recommendation = o.recommendation;
  if (o.confidence !== undefined) confidence = o.confidence;
  if (o.reasoning !== undefined) reasoning = o.reasoning;
  else if (o.reason !== undefined) reasoning = o.reason;
  return recommendation !== null || confidence !== null || reasoning !== null;
}

if (!fromObject(out)) {
  const text = typeof out === 'string' ? out : JSON.stringify(out ?? '');

  // The agent may return JSON wrapped in prose or a ```json fence.
  let parsed = null;
  const braced = text.match(/\{[\s\S]*\}/);
  if (braced) {
    try { parsed = JSON.parse(braced[0]); } catch (e) { parsed = null; }
  }

  if (!fromObject(parsed)) {
    const rec = text.match(/Recommendation\s*[:\-]\s*(Approve\w*|Reject\w*|Request\s*Info)/i);
    const conf = text.match(/Confidence\s*[:\-]\s*(\d+(?:\.\d+)?)\s*(%?)/i);
    const why = text.match(/Reasoning\s*[:\-]\s*([\s\S]*)/i);

    if (rec) recommendation = rec[1];
    if (conf) confidence = Number(conf[1]);
    if (why) reasoning = why[1].trim();

    // Last resort: look for a bare verdict word anywhere in the text.
    if (!recommendation) {
      if (/\brequest\s*info\b/i.test(text)) recommendation = 'Request Info';
      else if (/\breject/i.test(text)) recommendation = 'Reject';
      else if (/\bapprove/i.test(text)) recommendation = 'Approve';
    }
    if (!reasoning && text.trim()) reasoning = text.trim();
  }
}

// Canonicalise the verdict.
if (typeof recommendation === 'string') {
  const r = recommendation.trim().toLowerCase();
  if (r.startsWith('approve')) recommendation = 'Approve';
  else if (r.startsWith('reject')) recommendation = 'Reject';
  else if (r.replace(/[\s_-]/g, '').startsWith('requestinfo')) recommendation = 'Request Info';
  else recommendation = null;
} else {
  recommendation = null;
}

// decisions.confidence has CHECK (confidence >= 0 AND confidence <= 1),
// so a 0-100 percentage has to be scaled down before it is stored.
// Guard the empty cases first: Number(null) is 0, which would silently
// store a real "zero confidence" for an answer we simply could not parse.
if (confidence === null || confidence === undefined || confidence === '') {
  confidence = null;
} else {
  confidence = Number(confidence);
  if (!Number.isFinite(confidence)) {
    confidence = null;
  } else {
    if (confidence > 1) confidence = confidence / 100;
    confidence = Math.min(1, Math.max(0, confidence));
    confidence = Math.round(confidence * 1000) / 1000;
  }
}

if (typeof reasoning === 'string') {
  reasoning = reasoning.trim() || null;
} else if (reasoning != null) {
  reasoning = String(reasoning);
} else {
  reasoning = null;
}

const errors = [];
if (!recommendation) errors.push('Could not parse a recommendation');
if (confidence === null) errors.push('Could not parse a confidence value');
if (!reasoning) errors.push('Missing reasoning');

// The requests row inserted upstream in this execution.
// NOTE: deliberately NOT $('request table').item — paired-item resolution has to
// walk back through the Merge node and the agent sub-runs, and from inside the
// sandboxed task runner that RPC never returns, so the Code node gets killed at
// the 300s task timeout. .all() is a direct fetch of the node's output: no walk.
const requestRows = $('request table').all();
const requestRow = requestRows[$runIndex] || requestRows[0];
const requestId = requestRow && requestRow.json ? requestRow.json.id : null;
if (!requestId) {
  throw new Error('No requests row found upstream - cannot link this decision.');
}

return [{
  json: {
    request_id: requestId,

    // HR stays in the loop: the AI's own verdict lives in ai_recommendation.
    status: 'needs_review',

    confidence: confidence,
    decision_reason: reasoning,
    ai_recommendation: recommendation,
    notes: errors.length ? errors.join('; ') : null,

    is_valid: errors.length === 0,
    raw_output: typeof out === 'string' ? out : JSON.stringify(out ?? null),
  },
}];
""".strip()

DECISION_FIELDS = [
    {"fieldId": "request_id", "fieldValue": "={{ $json.request_id }}"},
    {"fieldId": "status", "fieldValue": "={{ $json.status }}"},
    {"fieldId": "confidence", "fieldValue": "={{ $json.confidence }}"},
    {"fieldId": "decision_reason", "fieldValue": "={{ $json.decision_reason }}"},
    {"fieldId": "ai_recommendation", "fieldValue": "={{ $json.ai_recommendation }}"},
    {"fieldId": "notes", "fieldValue": "={{ $json.notes }}"},
]

DECISION_CODE_NODES = [
    "Code in JavaScript",   # leave
    "Code in JavaScript2",  # flexwork
    "Code in JavaScript3",  # salary
]

DECISION_INSERT_NODES = [
    "desicions table",  # leave
    "Create a row1",    # flexwork
    "Create a row",     # salary
]


def main(src: Path, dst: Path) -> None:
    wf = json.loads(src.read_text(encoding="utf-8"))
    nodes = {n["name"]: n for n in wf["nodes"]}
    conns = wf["connections"]
    changes = []

    # --- Fix 1: one tolerant parser on all three agent branches, and it is
    # the parser that resolves request_id from the upstream requests row.
    for name in DECISION_CODE_NODES:
        nodes[name]["parameters"]["jsCode"] = DECISION_PARSER_JS
        changes.append(f"{name}: rewrote parser (request_id, 0-1 confidence, valid status)")

    # --- Fix 2: every decisions insert maps all six columns, request_id included.
    for name in DECISION_INSERT_NODES:
        params = nodes[name]["parameters"]
        params["tableId"] = "decisions"
        params["fieldsUi"] = {"fieldValues": [dict(f) for f in DECISION_FIELDS]}
        changes.append(f"{name}: mapped request_id + all decision columns")

    # --- Fix 3: put "request table" in the main line so its inserted row (and
    # its id) is an ancestor of the decision branches.
    conns["Parse Category"]["main"][0] = [
        {"node": "request table", "type": "main", "index": 0}
    ]
    conns["request table"] = {
        "main": [[{"node": "Merge", "type": "main", "index": 1}]]
    }
    changes.append("Parse Category -> request table -> Merge[1] (was a sibling branch)")

    # The router now reads the value off the inserted row. requests.request_type
    # holds exactly the same values Parse Category produced.
    for rule in nodes["Supervisor Router"]["parameters"]["rules"]["values"]:
        for cond in rule["conditions"]["conditions"]:
            if cond["leftValue"] == "={{ $json.category }}":
                cond["leftValue"] = "={{ $json.request_type }}"
    changes.append("Supervisor Router: $json.category -> $json.request_type")

    # --- Fix 4: store the bare lowercased address, not the raw From header.
    for a in nodes["Normalize Email"]["parameters"]["assignments"]["assignments"]:
        if a["name"] == "email_from":
            a["value"] = (
                "={{ ($json.From.match(/<(.*)>/) ? $json.From.match(/<(.*)>/)[1] "
                ": $json.From).toLowerCase().trim() }}"
            )
            changes.append("Normalize Email: email_from now the bare lowercased address")

    # --- Import as a new workflow rather than overwriting the original.
    # Pass an existing id as argv[3] to update that workflow in place instead.
    wf["id"] = sys.argv[3] if len(sys.argv) > 3 else uuid.uuid4().hex[:16]
    wf["name"] = NEW_NAME
    wf["active"] = False
    for key in ("versionId", "activeVersionId", "triggerCount", "shared", "meta"):
        wf.pop(key, None)

    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(json.dumps(wf, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"Wrote {dst}")
    print(f"  new workflow id:   {wf['id']}")
    print(f"  new workflow name: {wf['name']}")
    for c in changes:
        print(f"  - {c}")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
