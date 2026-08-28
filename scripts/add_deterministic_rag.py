"""
Makes policy retrieval deterministic instead of leaving it to the agent.

Why: measured across 7 real executions, each agent made exactly 2 LLM calls -
one to pick a tool, one to answer. It never made a third call, so it used
whichever tool it picked first and the policy vector store was consulted in
only 3 of 7 runs. llama3.2:3b cannot reliably chain two tool calls, and no
amount of "Always call both tools" in the system prompt changes that.

Fix: pull the policy out of the agent's hands.

    Supervisor Router -> Retrieve <X> Policy (vector store, mode=load)
                      -> Build <X> Prompt (code)
                      -> <x> agent

The retrieve node always runs, so the policy text is always fetched and
injected into the agent's chatInput. The vector-store *tool* connection is then
removed from each agent, leaving it a single tool (the employee database) -
which a 3B model handles reliably. Both information sources are now guaranteed:
the policy by construction, the employee data by a one-tool call.

The old retrieve-as-tool nodes are left in place but disconnected, so the
previous behaviour can be restored by re-adding the ai_tool connection.

Usage:
    py scripts/add_deterministic_rag.py <in.json> <out.json> [workflow_id]
"""

import json
import sys
import uuid
from pathlib import Path

# branch -> (router output index, agent, policy tool node to unwire,
#            table, match function, embeddings node, label)
BRANCHES = [
    (0, "leave request agent", "the company vacation leave policy",
     "leave_documents", "match_leave_documents", "Embeddings Ollama2", "Leave"),
    (1, "salary request agent", "Supabase Vector Store4",
     "salary_documents", "match_salary_documents", "Embeddings Ollama", "Salary"),
    (2, "flexible work agent", "Supabase Vector Store3",
     "flexwork_documents", "match_flexwork_documents", "Embeddings Ollama1", "Flexwork"),
]

BUILD_PROMPT_JS = r"""
// Fold the retrieved policy excerpts into the agent's prompt.
// Deliberately uses .all() rather than .item - a paired-item lookup here has to
// walk back through the Merge node and never returns inside the task runner.
const ctxRuns = $('Merge').all();
const ctx = ((ctxRuns[$runIndex] || ctxRuns[0] || {}).json) || {};

const seen = new Set();
const excerpts = [];
for (const item of $input.all()) {
  const doc = item.json && item.json.document;
  const text = doc && typeof doc.pageContent === 'string' ? doc.pageContent.trim() : '';
  if (!text || seen.has(text)) continue;   // guard against duplicate chunks
  seen.add(text);
  excerpts.push(text);
}

const policy = excerpts.length
  ? excerpts.map((t, i) => `[Policy excerpt ${i + 1}]\n${t}`).join('\n\n')
  : '(No policy excerpts were retrieved for this request.)';

const email = ctx.chatInput || ctx.request_text || '';

// llama3.2:3b drops the output format when the policy block pushes the
// instructions far up the prompt - it starts emitting invented tool calls as
// plain text. Small models weight the END of the prompt most, so the format is
// restated last.
const task = [
  '=== YOUR TASK ===',
  'Look up the employee with the Employee Database tool, compare the request',
  'against the policy excerpts above, then reply with EXACTLY these three lines',
  'and nothing else:',
  'Recommendation: Approve | Reject | Request Info',
  'Confidence: <0-100>%',
  'Reasoning: <short paragraph citing the policy rule and the employee data used>',
  '',
  'Do NOT output tool-call syntax, JSON, or any other text.',
].join('\n');

const out = {
  json: {
    ...ctx,
    retrieved_policy: policy,
    policy_excerpt_count: excerpts.length,
    chatInput:
      `${email}\n\n=== COMPANY POLICY (retrieved for this request) ===\n${policy}\n\n${task}`,
  },
};

// The agent's memory sub-node traces item lineage, so this collapsed item has to
// declare which input it came from. Without pairedItem the agent fails with
// "Paired item data for item from node '...' is unavailable".
if ($input.all().length > 0) {
  out.pairedItem = { item: 0 };
}

return [out];
""".strip()


def main(src: Path, dst: Path, wf_id: str | None) -> None:
    wf = json.loads(src.read_text(encoding="utf-8"))
    nodes = {n["name"]: n for n in wf["nodes"]}
    conns = wf["connections"]
    changes = []

    # Reuse the Supabase credential already on the policy tool nodes.
    creds = nodes["the company vacation leave policy"].get("credentials", {})

    for idx, agent, tool_node, table, query_name, emb_node, label in BRANCHES:
        retrieve = f"Retrieve {label} Policy"
        build = f"Build {label} Prompt"
        base = nodes[agent]["position"]

        nodes[retrieve] = {
            "parameters": {
                "mode": "load",
                "tableName": {"__rl": True, "value": table, "mode": "list",
                              "cachedResultName": table},
                # the summary is the focused version of the request; fall back to the email
                "prompt": "={{ $json.summary || $json.chatInput }}",
                "topK": 3,   # keep the policy block short for a 3B model
                "includeDocumentMetadata": False,
                "options": {"queryName": query_name},
            },
            "id": str(uuid.uuid4()),
            "name": retrieve,
            "type": "@n8n/n8n-nodes-langchain.vectorStoreSupabase",
            "typeVersion": 1.3,
            "position": [base[0] - 460, base[1]],
            "credentials": creds,
        }
        nodes[build] = {
            "parameters": {"jsCode": BUILD_PROMPT_JS},
            "id": str(uuid.uuid4()),
            "name": build,
            "type": "n8n-nodes-base.code",
            "typeVersion": 2,
            "position": [base[0] - 240, base[1]],
        }

        # Router -> retrieve -> build -> agent
        conns["Supervisor Router"]["main"][idx] = [
            {"node": retrieve, "type": "main", "index": 0}]
        conns[retrieve] = {"main": [[{"node": build, "type": "main", "index": 0}]]}
        conns[build] = {"main": [[{"node": agent, "type": "main", "index": 0}]]}

        # the retrieve node needs its embeddings model
        emb = conns.setdefault(emb_node, {}).setdefault("ai_embedding", [[]])
        emb[0].append({"node": retrieve, "type": "ai_embedding", "index": 0})

        # drop the vector store *tool* from the agent - it is redundant now, and
        # one fewer tool makes the single tool call the model does make count.
        tool_conns = conns.get(tool_node, {}).get("ai_tool")
        if tool_conns:
            tool_conns[0] = [c for c in tool_conns[0] if c["node"] != agent]

        changes.append(f"{label}: Router[{idx}] -> {retrieve} -> {build} -> {agent}"
                       f"; unwired {tool_node} as a tool")

    # The system prompts told the model to call a policy tool that is now gone.
    for _, agent, _, _, _, _, label in BRANCHES:
        opts = nodes[agent]["parameters"].setdefault("options", {})
        msg = opts.get("systemMessage", "")
        lines, out = msg.split("\n"), []
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("2. Always call the Company"):
                out.append(
                    "2. The relevant policy excerpts are already included in the message "
                    "below, under \"=== COMPANY POLICY (retrieved for this request) ===\". "
                    "Read them there - there is no policy tool to call.")
            elif stripped.startswith("3. Compare the request against BOTH"):
                out.append(
                    "3. Compare the request against BOTH the employee's data and the "
                    "policy excerpts in the message before deciding.")
            else:
                out.append(line)
        opts["systemMessage"] = "\n".join(out)
        changes.append(f"{label}: system message now points at the injected policy")

    wf["nodes"] = list(nodes.values())
    if wf_id:
        wf["id"] = wf_id
    for k in ("versionId", "activeVersionId", "triggerCount", "shared", "meta"):
        wf.pop(k, None)

    dst.write_text(json.dumps(wf, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {dst}  (id={wf['id']}, name={wf['name']!r})")
    for c in changes:
        print(f"  - {c}")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]),
         sys.argv[3] if len(sys.argv) > 3 else None)
