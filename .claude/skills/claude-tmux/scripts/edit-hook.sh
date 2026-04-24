#!/usr/bin/env bash
# PostToolUse hook — mirrors the edited file in a persistent right-side nvim pane,
# scrolled to the chunk that was just edited.
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

# Derive a text anchor for the edited region, then resolve it to a line number
# by searching the post-edit file. Longer lines are more likely to be unique,
# so we pick the longest non-blank line from the first 30 lines of new content.
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
snippet=""
case "$tool" in
  Edit)
    snippet=$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty')
    ;;
  MultiEdit)
    snippet=$(printf '%s' "$input" | jq -r '(.tool_input.edits // []) | last | .new_string // empty')
    ;;
esac

start=""; end=""
if [[ -n "$snippet" && -f "$abs" ]]; then
  anchor=$(printf '%s' "$snippet" | head -n 30 | awk 'NF && length($0) > best_len { best_len = length($0); best = $0 } END { print best }')
  if [[ -n "$anchor" ]]; then
    anchor_file_line=$(grep -nF -- "$anchor" "$abs" 2>/dev/null | head -n1 | cut -d: -f1)
    if [[ -n "$anchor_file_line" ]]; then
      # Line number of the anchor inside new_string (1-based), and total line count.
      anchor_snippet_line=$(printf '%s' "$snippet" | head -n 30 | awk -v a="$anchor" '$0==a{print NR; exit}')
      snippet_lines=$(printf '%s' "$snippet" | awk 'END{print NR+(length($0)>0?0:0)}')
      [[ -z "$anchor_snippet_line" ]] && anchor_snippet_line=1
      [[ -z "$snippet_lines" || "$snippet_lines" == "0" ]] && snippet_lines=1
      start=$(( anchor_file_line - anchor_snippet_line + 1 ))
      (( start < 1 )) && start=1
      end=$(( start + snippet_lines - 1 ))
    fi
  fi
fi

if [[ -n "$start" && -n "$end" ]]; then
  ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh edit-show --file "$abs" --start "$start" --end "$end" >/dev/null 2>&1 || true
else
  ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh edit-show --file "$abs" >/dev/null 2>&1 || true
fi
exit 0
