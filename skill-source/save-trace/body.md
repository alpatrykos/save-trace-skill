# save-trace

## Purpose
Design and implement structured, append-only trace persistence for agent runs so the resulting data can support debugging, evaluation, harness improvement, and memory extraction.

The trace system should capture task inputs, execution summaries, tool activity, outputs, errors, and metadata without storing raw chain-of-thought.

Use the examples in `references/trace-schema.example.json` and `references/index-row.example.json` when the target repository does not already define a stronger trace format.

## Use this skill when
- The user asks to save traces, persist agent runs, record tool calls, or add execution history for an agent.
- The user wants logs that can later support evals, memory extraction, or harness tuning.
- The system already has an agent loop and needs structured trace storage.
- The task is to normalize ad hoc agent logging into a reusable trace format.

## Do not use this skill when
- The task is about stack traces, exception debugging, or crash dumps.
- The task is about distributed tracing, OpenTelemetry spans, request tracing, or APM and does not explicitly involve agent execution persistence.
- The task is only about metrics, counters, dashboards, or generic application logs.
- The task is only about prompt logging with no request for structured execution traces.

## Core rules
1. Reuse the repository's existing language, testing framework, config conventions, logging helpers, and persistence layer when they already exist.
2. Prefer the smallest implementation that satisfies the trace requirements.
3. Do not add a new database, queue, or third-party dependency unless the repository already uses it or the user explicitly asks for it.
4. Save summaries of actions and decisions, not raw chain-of-thought.
5. Redact secrets and obvious sensitive values before persistence.
6. Make persistence best-effort and non-blocking where practical.
7. Favor append-only storage and stable schemas.
8. Add tests for redaction and at least one success and one failure path.

## Required trace behavior
A valid implementation should support these concepts even if names differ to match the local codebase:

- `trace_id`: unique identifier for a trace
- `session_id` or equivalent grouping key
- `parent_trace_id`: optional link for retries, subruns, or child agents
- `timestamp_start`
- `timestamp_end`
- `status`: `success`, `failure`, `interrupted`, or repo-equivalent
- normalized task input
- execution step summaries
- tool call summaries
- error summaries
- final output or output reference
- tags or searchable text
- privacy or redaction metadata

## Required trace fields
Unless the repository has a stronger schema already, include a structure equivalent to:

```json
{
  "schema_version": "1.0",
  "trace_id": "trc_20260408_8f3a2c",
  "session_id": "sess_91b2",
  "parent_trace_id": null,
  "timestamp_start": "2026-04-08T18:10:04Z",
  "timestamp_end": "2026-04-08T18:10:22Z",
  "task": {
    "type": "question_answering",
    "intent": "design_skill",
    "input": "design a skill for saving traces",
    "normalized_input": "Design an agent skill that saves traces for later analysis."
  },
  "execution": {
    "status": "success",
    "outcome_summary": "Produced trace-saving skill design with schema, triggers, storage, and safeguards.",
    "steps": [
      {
        "step_id": "s1",
        "type": "reasoning_summary",
        "summary": "Defined purpose, triggers, schema, storage, and privacy controls."
      }
    ],
    "tool_calls": [],
    "errors": []
  },
  "result": {
    "final_output": "Here is a solid agent skill for saving traces...",
    "output_hash": "sha256:abc123"
  },
  "privacy": {
    "contains_pii": false,
    "redactions_applied": []
  },
  "tags": ["trace", "observability", "agent", "skill"],
  "search_text": "saving traces skill structured trace storage agent workflow"
}
```

## Redaction rules
Before saving any trace data:
- remove or mask API keys, bearer tokens, cookies, auth headers, secrets, and credentials
- mask email addresses, phone numbers, exact addresses, and similar obvious PII when practical
- truncate very large payloads
- replace sensitive raw values with `[REDACTED]`
- avoid storing raw chain-of-thought or hidden reasoning

## Storage rules
Prefer this shape unless the repo already has a better convention:
- raw traces: append-only JSON files or JSONL records
- searchable index: compact JSONL or database row containing metadata and search text
- file layout example: `traces/YYYY/MM/DD/{trace_id}.json`
- index example: `traces/index/YYYY-MM.jsonl`

If the repository already has a storage abstraction, plug into it instead of creating parallel infrastructure.

## Checkpoint rules
Persist traces at:
- successful completion
- failure
- timeout or interruption
- major checkpoints in long-running workflows
- risky actions if the local architecture supports pre-action checkpoints

Do not rely only on final save for long workflows.

## Implementation workflow
When using this skill in a repository, follow this order:

1. Inspect the codebase to locate:
   - the main agent loop or orchestration path
   - existing logging or persistence utilities
   - config or feature flag patterns
   - existing test conventions
2. Identify the smallest integration point for trace capture.
3. Add or reuse a trace model/schema.
4. Add a redaction layer before persistence.
5. Add a writer or sink abstraction if one does not already exist.
6. Add save hooks for success, failure, and checkpoints.
7. Add or update a lightweight search/index record.
8. Add tests.
9. Update docs if the repository documents developer workflows.

## Preferred architecture
Prefer a small separation like:
- trace collector or buffer in memory during execution
- trace builder that produces the final normalized record
- redactor that sanitizes sensitive content
- writer or sink that persists the result
- optional index writer for lightweight retrieval

Keep the design modular enough that a later task can swap storage backends without changing the trace schema.

## Validation checklist
Before finishing, verify that:
- the implementation stores structured traces instead of plain string logs
- the implementation does not persist raw chain-of-thought
- secrets are redacted before persistence
- success and failure cases both produce trace output
- long-running workflows can save at checkpoints when appropriate
- tests cover at least one redaction path and one failure path
- no unnecessary heavy dependency was added

See `references/checklist.md` for the packaged skill checklist.

## Completion report
When you finish a task using this skill, report:
- files created or changed
- integration points chosen
- storage mechanism used
- redaction approach used
- tests added or run
- any limitations or follow-up work
