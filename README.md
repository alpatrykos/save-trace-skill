# Save Trace

`save-trace` is a skill for adding persistent, structured execution traces to an AI agent, assistant, or tool-using workflow.

In plain terms: when a repository already has an agent loop and you want to keep useful run history for debugging, evals, harness tuning, or memory extraction, this skill tells the agent how to add that trace layer safely and with minimal infrastructure.

## What This Skill Does

The skill guides the agent to:

- find the smallest integration point in the existing agent loop
- reuse the repository's current language, storage, config, and test patterns
- persist append-only traces for success, failure, interruptions, and long-running checkpoints
- save structured summaries of execution, tool activity, outputs, and errors
- redact secrets and obvious sensitive data before anything is written
- avoid storing raw chain-of-thought
- add tests for redaction plus at least one success path and one failure path

Use it for:

- agent-run execution history
- structured traces that can later support evals or memory extraction
- normalizing ad hoc agent logging into a reusable schema

## Expected Trace Shape

The skill expects a trace model that covers the essentials even if field names differ in the target codebase:

- `trace_id`
- `session_id`
- optional `parent_trace_id`
- start and end timestamps
- normalized task input
- execution status
- step summaries
- tool call summaries
- error summaries
- final output or output reference
- tags or searchable text
- privacy and redaction metadata

Reference examples are included here:

- [`skill-source/save-trace/references/trace-schema.example.json`](skill-source/save-trace/references/trace-schema.example.json)
- [`skill-source/save-trace/references/index-row.example.json`](skill-source/save-trace/references/index-row.example.json)

## Generate The Packages

Run:

```bash
./scripts/generate-skill-packages.sh
```

That script builds:

- the agent (Codex) package in [`.agents/skills/save-trace`](.agents/skills/save-trace)
- the Claude package in [`.claude/skills/save-trace`](.claude/skills/save-trace)

## How To Use The Skill

Typical prompt:

```text
Use $save-trace to add persistent structured execution traces for this agent workflow.
```

Good requests for this skill:

- "Add structured trace persistence to this tool-using agent."
- "Save agent runs so we can inspect failures later."
- "Normalize this ad hoc agent logging into searchable JSON traces."

Bad requests for this skill:

- "Help debug this stack trace."
- "Add OpenTelemetry spans."
- "Set up application metrics and dashboards."

## License

[MIT](LICENSE)
