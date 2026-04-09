#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/skill-source/save-trace"

render_skill() {
  local frontmatter_file="$1"
  local output_dir="$2"
  local checklist_file="$3"

  mkdir -p "$output_dir/references"
  cat "$frontmatter_file" "$SOURCE_DIR/body.md" > "$output_dir/SKILL.md"
  cp "$SOURCE_DIR/references/trace-schema.example.json" "$output_dir/references/trace-schema.example.json"
  cp "$SOURCE_DIR/references/index-row.example.json" "$output_dir/references/index-row.example.json"
  cp "$checklist_file" "$output_dir/references/checklist.md"
}

verify_codex_package() {
  local output_dir="$1"

  if ! rg -q '^  allow_implicit_invocation: false$' "$output_dir/agents/openai.yaml"; then
    printf 'Codex package is missing policy.allow_implicit_invocation: false in %s\n' \
      "$output_dir/agents/openai.yaml" >&2
    exit 1
  fi
}

verify_claude_package() {
  local output_dir="$1"

  if ! rg -q '^disable-model-invocation: true$' "$output_dir/SKILL.md"; then
    printf 'Claude package is missing disable-model-invocation: true in %s\n' \
      "$output_dir/SKILL.md" >&2
    exit 1
  fi
}

CODEX_DIR="$ROOT_DIR/.agents/skills/save-trace"
CLAUDE_DIR="$ROOT_DIR/.claude/skills/save-trace"

render_skill \
  "$SOURCE_DIR/frontmatter.codex.md" \
  "$CODEX_DIR" \
  "$SOURCE_DIR/references/checklist.codex.md"
mkdir -p "$CODEX_DIR/agents"
cp "$SOURCE_DIR/agents/openai.yaml" "$CODEX_DIR/agents/openai.yaml"
verify_codex_package "$CODEX_DIR"

render_skill \
  "$SOURCE_DIR/frontmatter.claude.md" \
  "$CLAUDE_DIR" \
  "$SOURCE_DIR/references/checklist.claude.md"
verify_claude_package "$CLAUDE_DIR"

printf 'Generated skill packages in:\n- %s\n- %s\n' "$CODEX_DIR" "$CLAUDE_DIR"
