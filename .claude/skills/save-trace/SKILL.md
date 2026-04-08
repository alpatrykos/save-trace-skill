---
name: save-trace
description: Use this skill only when the task is to add or improve persistent structured execution traces for an AI agent, assistant, tool-using workflow, or orchestration harness. This skill is for agent-run traces and memory or eval oriented execution records. Do not use it for stack traces, distributed tracing, APM, metrics-only instrumentation, or generic application logging unless the request explicitly requires persistent agent execution traces.
disable-model-invocation: true
---

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
8. Add tests for redaction, at least one success path, at least one execution failure path, and one trace sink failure path when practical.

## Required trace behavior
A valid implementation should support these concepts even if names differ to match the local codebase:

- `trace_id`: unique identifier for a trace
- `session_id` or equivalent grouping key
- `parent_trace_id`: optional link for retries, subruns, or child agents
- `record_kind` or equivalent marker when checkpoint records and final records both exist
- `checkpoint_seq` or equivalent monotonic ordering field when multiple records can exist for one trace
- `timestamp_start`
- `timestamp_end`
- `status`: `in_progress`, `success`, `failure`, `interrupted`, or repo-equivalent when checkpoints are emitted
- normalized task input or a redacted input reference
- execution step summaries
- tool call summaries with tool name, status, and timing
- error summaries with type, stage, and message summary
- final output or output reference
- tags or searchable text derived from redacted content only
- privacy or redaction metadata

## Checkpoint model
Pick one append-only checkpoint model and keep it consistent for a given implementation:

- event log plus a final summary record
- append-only snapshots with one record per checkpoint and one terminal final record

If using append-only snapshots, each record should include:

- `record_kind`: `checkpoint` or `final`, or repo-equivalent
- `checkpoint_seq`: monotonic sequence number
- `is_terminal`
- nullable `timestamp_end` until the terminal record is written

Do not rewrite the same trace file in place to simulate append-only checkpoints.

## Required trace fields
Unless the repository has a stronger schema already, include a structure equivalent to:

```json
{
  "schema_version": "1.1",
  "trace_id": "trc_20260408_8f3a2c",
  "session_id": "sess_91b2",
  "parent_trace_id": null,
  "record_kind": "final",
  "checkpoint_seq": 3,
  "is_terminal": true,
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
    "outcome_summary": "Produced trace-saving skill design with schema, checkpoints, storage, and safeguards.",
    "steps": [
      {
        "step_id": "s1",
        "type": "decision_summary",
        "summary": "Defined purpose, triggers, schema, checkpoint model, storage, and privacy controls."
      }
    ],
    "tool_calls": [
      {
        "call_id": "call_1",
        "tool_name": "inspect_repository",
        "status": "success",
        "started_at": "2026-04-08T18:10:05Z",
        "ended_at": "2026-04-08T18:10:08Z",
        "input_summary": "Inspected the existing skill package and reference files.",
        "output_summary": "Loaded the current schema and checklist examples."
      }
    ],
    "errors": []
  },
  "result": {
    "final_output": "Here is a solid agent skill for saving traces...",
    "output_hash": "sha256:abc123"
  },
  "privacy": {
    "contains_pii": false,
    "redactions_applied": [],
    "search_text_source": "redacted_content_only"
  },
  "tags": ["trace", "observability", "agent", "skill"],
  "search_text": "saving traces skill structured trace storage agent workflow"
}
```

For checkpoint records, set `record_kind` to `checkpoint`, keep `is_terminal` false, and allow `timestamp_end` to stay null until the terminal record is written.

## Tool and error summaries
Each tool call summary should capture:

- `call_id`
- `tool_name`
- `status`
- `started_at` and `ended_at`, or a duration field
- a redacted `input_summary`
- a redacted `output_summary` or `output_ref`

Each error summary should capture:

- `error_type`
- `stage` or source
- a short message summary
- retry or related-call metadata when applicable

## Redaction rules
Before saving any trace data:
- remove or mask API keys, bearer tokens, cookies, auth headers, secrets, and credentials
- mask email addresses, phone numbers, exact addresses, and similar obvious PII when practical
- truncate very large payloads
- replace sensitive raw values with `[REDACTED]`
- derive `search_text` only from already-redacted or otherwise safe summary fields
- when task inputs or tool payloads are too large or sensitive, store a redacted summary, hash, or reference instead of the raw value
- avoid storing raw chain-of-thought or hidden reasoning

## Storage rules
Prefer this shape unless the repo already has a better convention:
- raw traces: append-only JSONL records, append-only event tables, or one JSON file per checkpoint or final record
- searchable index: compact JSONL or database row containing redacted metadata and search text
- checkpointed file layout example: `traces/YYYY/MM/DD/{trace_id}/{checkpoint_seq}.json`
- per-trace stream example: `traces/YYYY/MM/DD/{trace_id}.jsonl`
- index example: `traces/index/YYYY-MM.jsonl`

If the repository already has a storage abstraction, plug into it instead of creating parallel infrastructure.
Do not rewrite the same file in place to emulate append-only checkpoints.
Follow the repository's existing retention, TTL, or rotation conventions when they exist. If none exist, make retention configurable and avoid unbounded growth.

## Sink failure rules
Trace persistence must not cause the main task to fail just because a trace write failed.

When a trace write fails, surface it through the repository's existing logger, metric, or error reporting path and continue with the main execution whenever possible.

If the architecture already supports fallback sinks or retry queues, reuse them instead of inventing new infrastructure.

## Checkpoint rules
Persist traces at:
- successful completion
- failure
- timeout or interruption
- major checkpoints in long-running workflows
- risky actions if the local architecture supports pre-action checkpoints

When checkpoints are emitted, keep their ordering explicit and produce one terminal record for the completed run.

Do not rely only on final save for long workflows.

## Implementation workflow
When using this skill in a repository, follow this order:

1. Inspect the codebase to locate:
   - the main agent loop or orchestration path
   - existing logging or persistence utilities
   - config or feature flag patterns
   - existing test conventions
2. Identify the smallest integration point for trace capture.
3. Choose an explicit checkpoint model.
4. Add or reuse a trace model/schema.
5. Add a redaction layer before persistence.
6. Add a writer or sink abstraction if one does not already exist.
7. Add save hooks for success, failure, and checkpoints.
8. Add or update a lightweight search/index record derived from redacted content only.
9. Add tests.
10. Update docs if the repository documents developer workflows.

## Preferred architecture
Prefer a small separation like:
- trace collector or buffer in memory during execution
- trace builder that produces the final normalized record
- redactor that sanitizes sensitive content
- writer or sink that persists the result
- optional index writer for lightweight retrieval
- optional event or snapshot translator when the repository needs both checkpoint and final views

Keep the design modular enough that a later task can swap storage backends without changing the trace schema.

## Validation checklist
Before finishing, verify that:
- the implementation stores structured traces instead of plain string logs
- the implementation does not persist raw chain-of-thought
- secrets are redacted before persistence
- `search_text` is derived from redacted or otherwise safe content only
- success and failure cases both produce trace output
- checkpoint records have explicit ordering and a terminal state
- tool calls and errors are stored with enough metadata to debug later
- trace sink failures are surfaced without breaking the main task
- long-running workflows can save at checkpoints when appropriate
- tests cover at least one redaction path, one execution failure path, and one trace sink failure path when practical
- no unnecessary heavy dependency was added

See `references/checklist.md` for the packaged skill checklist.

## Completion report
When you finish a task using this skill, report:
- files created or changed
- integration points chosen
- checkpoint model chosen
- storage mechanism used
- redaction approach used
- sink failure behavior
- tests added or run
- any limitations or follow-up work
