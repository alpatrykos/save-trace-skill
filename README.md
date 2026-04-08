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

## What This Skill Is Not For

This skill is intentionally narrow.

Use it for:

- agent-run execution history
- structured traces that can later support evals or memory extraction
- normalizing ad hoc agent logging into a reusable schema

Do not use it for:

- stack traces or crash debugging
- distributed tracing or OpenTelemetry spans
- APM instrumentation
- generic application logs
- metrics-only dashboards or counters

## Core Behavior

When the skill is used, it pushes the implementation toward a few strong defaults:

1. Keep the implementation small.
2. Reuse existing repo patterns instead of inventing new infrastructure.
3. Prefer append-only storage with a stable schema.
4. Persist summaries, not hidden reasoning.
5. Redact secrets and obvious PII before persistence.
6. Make trace saving best-effort and non-blocking where practical.

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

## Repository Layout

This repository keeps the source material separate from the generated skill packages.

```text
skill-source/save-trace/
  frontmatter.codex.md
  frontmatter.claude.md
  body.md
  agents/openai.yaml
  references/

scripts/
  generate-skill-packages.sh

.agents/skills/save-trace/
  SKILL.md
  agents/openai.yaml
  references/

.claude/skills/save-trace/
  SKILL.md
  references/
```

## Source Of Truth

Edit these files when changing the skill:

- [`skill-source/save-trace/frontmatter.codex.md`](skill-source/save-trace/frontmatter.codex.md)
- [`skill-source/save-trace/frontmatter.claude.md`](skill-source/save-trace/frontmatter.claude.md)
- [`skill-source/save-trace/body.md`](skill-source/save-trace/body.md)
- [`skill-source/save-trace/agents/openai.yaml`](skill-source/save-trace/agents/openai.yaml)
- files under [`skill-source/save-trace/references`](skill-source/save-trace/references)

The packaged skill files under [`.agents/skills/save-trace`](.agents/skills/save-trace) and [`.claude/skills/save-trace`](.claude/skills/save-trace) are generated output.

## Generate The Packages

Run:

```bash
./scripts/generate-skill-packages.sh
```

That script builds:

- the Codex package in [`.agents/skills/save-trace`](.agents/skills/save-trace)
- the Claude package in [`.claude/skills/save-trace`](.claude/skills/save-trace)

## How To Use The Skill

In Codex, this skill is explicit-invocation only. That is deliberate because the word "trace" is overloaded and can easily be confused with stack traces or observability tooling.

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

## Design Constraints

The skill deliberately enforces a few safeguards:

- no raw chain-of-thought persistence
- redaction before persistence
- no heavy new infrastructure unless the repository already uses it or the user asks for it
- tests for both normal and failure behavior

## Included Files

- [Codex skill package](.agents/skills/save-trace)
- [Claude skill package](.claude/skills/save-trace)
- [generator script](scripts/generate-skill-packages.sh)
- [original design spec](codex-save-trace-skill-design.md)

## License

[MIT](LICENSE)
