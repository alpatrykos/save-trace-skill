# save-trace checklist

## Skill package
- [ ] `SKILL.md` exists and has valid frontmatter
- [ ] `name` is `save-trace`
- [ ] `description` clearly distinguishes agent execution traces from stack traces and APM
- [ ] `agents/openai.yaml` exists
- [ ] `policy.allow_implicit_invocation: false` is set in `agents/openai.yaml`
- [ ] reference examples are present

## Skill behavior
- [ ] the instructions tell Codex to reuse existing repo patterns
- [ ] the instructions forbid raw chain-of-thought persistence
- [ ] the instructions require redaction before persistence
- [ ] the instructions require success and failure trace handling
- [ ] the instructions require tests
- [ ] the instructions discourage unnecessary infra and dependencies
