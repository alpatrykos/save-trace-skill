# save-trace checklist

## Skill package
- [ ] `SKILL.md` exists and has valid frontmatter
- [ ] `name` is `save-trace`
- [ ] `description` clearly distinguishes agent execution traces from stack traces and APM
- [ ] `disable-model-invocation: true` is set
- [ ] reference examples are present

## Skill behavior
- [ ] the instructions tell the agent to reuse existing repo patterns
- [ ] the instructions forbid raw chain-of-thought persistence
- [ ] the instructions require redaction before persistence
- [ ] the instructions require success and failure trace handling
- [ ] the instructions require tests
- [ ] the instructions discourage unnecessary infra and dependencies
