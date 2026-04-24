#!/usr/bin/env bash
# PostToolUse hook — mirrors the edited file in a persistent right-side nvim pane.
# MUST always exit 0: hooks run in the edit path and must never block a tool.
set -u

# Silent unless debugging.
exec 2>/dev/null

[[ -n "${TMUX:-}" ]] || exit 0
command -v nvim >/dev/null 2>&1 || exit 0
command -v jq   >/dev/null 2>&1 || exit 0

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
[[ -n "$file" ]] || exit 0

abs=$(readlink -f -- "$file" 2>/dev/null)
[[ -n "$abs" ]] || abs="$file"

~/.claude/skills/claude-tmux/scripts/tmux-pane.sh edit-show --file "$abs" >/dev/null 2>&1 || true
exit 0
