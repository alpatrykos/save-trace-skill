# save-trace checklist

## Skill package
- [ ] `SKILL.md` exists and has valid frontmatter
- [ ] `name` is `save-trace`
- [ ] `description` clearly distinguishes agent execution traces from stack traces and APM
- [ ] `agents/openai.yaml` exists
- [ ] implicit invocation is disabled
- [ ] reference examples are present
- [ ] mirrored assistant-specific packages, if present, are updated together

## Skill behavior
- [ ] the instructions tell Codex to reuse existing repo patterns
- [ ] the instructions forbid raw chain-of-thought persistence
- [ ] the instructions require an explicit append-only checkpoint model
- [ ] the instructions define minimum tool call and error metadata
- [ ] the instructions require redaction before persistence
- [ ] the instructions require `search_text` to come from redacted content only
- [ ] the instructions require success and failure trace handling
- [ ] the instructions explain how trace sink failures are surfaced without breaking primary execution
- [ ] the instructions require tests
- [ ] the instructions discourage unnecessary infra and dependencies
