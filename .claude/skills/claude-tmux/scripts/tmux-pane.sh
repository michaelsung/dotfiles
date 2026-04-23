#!/usr/bin/env bash
# tmux-pane.sh — helper for the claude-tmux skill.
# Manages a namespaced set of tmux panes titled "mgmt:<slug>" so Claude can
# run visible long-lived processes in a bottom strip without blocking its own shell.
set -euo pipefail

MGMT_PREFIX="mgmt:"
STRIP_HEIGHT="25%"
DEFAULT_CAPTURE_LINES=200

err() { echo "tmux-pane: $*" >&2; }
die() { err "$*"; exit 1; }
in_tmux() { [[ -n "${TMUX:-}" ]]; }
require_tmux() { in_tmux || die "not inside a tmux session (set \$TMUX or launch Claude from inside tmux)"; }
claude_pane() { echo "${TMUX_PANE:-}"; }

panes_by_title() {
  local title="$1"
  tmux list-panes -s -F '#{pane_id} #{pane_title}' \
    | awk -v t="$title" '$2==t{print $1}'
}

mgmt_long_lived_ids() {
  tmux list-panes -s -F '#{pane_left} #{pane_id} #{pane_title}' \
    | awk -v p="$MGMT_PREFIX" 'index($3,p)==1' \
    | sort -n \
    | awk '{print $2}'
}

restore_focus() {
  local cp
  cp=$(claude_pane)
  [[ -n "$cp" ]] && tmux select-pane -t "$cp" 2>/dev/null || true
}

rebalance_strip() {
  local ids=()
  while IFS= read -r id; do [[ -n "$id" ]] && ids+=("$id"); done < <(mgmt_long_lived_ids)
  local n=${#ids[@]}
  (( n >= 2 )) || return 0

  local total=0 w
  for p in "${ids[@]}"; do
    w=$(tmux display -p -t "$p" '#{pane_width}')
    total=$(( total + w ))
  done
  # +n-1 for inter-pane border columns, -n+1 to subtract them from distributable width
  local each=$(( total / n ))
  (( each > 0 )) || return 0
  # Set all but the last; last absorbs the slack from integer rounding.
  local i
  for ((i=0; i<n-1; i++)); do
    tmux resize-pane -t "${ids[$i]}" -x "$each" 2>/dev/null || true
  done
}

usage() {
  cat >&2 <<EOF
usage: tmux-pane.sh <verb> [flags]

verbs:
  check-env                                  exit 0 iff inside a tmux session
  spawn    --label <slug> -- <cmd...>        long-lived process, bottom strip
  list                                       list managed panes
  send     --label <slug> -- <text>          send literal text + Enter to a pane
  capture  --label <slug> [--lines N]        capture last N lines (default ${DEFAULT_CAPTURE_LINES})
  kill     --label <slug>                    kill a managed pane
EOF
}

cmd_check_env() {
  if in_tmux; then echo "ok"; exit 0; fi
  echo "not in tmux" >&2
  exit 1
}

cmd_spawn() {
  require_tmux
  local label="" cmd_args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --label) label="${2:-}"; shift 2;;
      --) shift; cmd_args=("$@"); break;;
      -h|--help) usage; exit 0;;
      *) die "unknown flag: $1";;
    esac
  done
  [[ -n "$label" ]] || die "spawn requires --label <slug>"
  [[ ${#cmd_args[@]} -gt 0 ]] || die "spawn requires -- <cmd...>"
  if [[ -n "$(panes_by_title "${MGMT_PREFIX}${label}")" ]]; then
    die "pane with label '$label' already exists (kill it first)"
  fi

  local cmd_str="${cmd_args[*]}"
  local existing new_pane cp target
  cp=$(claude_pane)
  existing=$(mgmt_long_lived_ids)

  if [[ -z "$existing" ]]; then
    target="${cp:-}"
    if [[ -n "$target" ]]; then
      new_pane=$(tmux split-window -v -l "$STRIP_HEIGHT" -t "$target" -P -F '#{pane_id}' "$cmd_str")
    else
      new_pane=$(tmux split-window -v -l "$STRIP_HEIGHT" -P -F '#{pane_id}' "$cmd_str")
    fi
  else
    target=$(echo "$existing" | head -n1)
    new_pane=$(tmux split-window -h -t "$target" -P -F '#{pane_id}' "$cmd_str")
  fi
  tmux select-pane -t "$new_pane" -T "${MGMT_PREFIX}${label}"
  tmux set-option -p -t "$new_pane" remain-on-exit on

  rebalance_strip
  restore_focus

  printf '%s %s%s\n' "$new_pane" "$MGMT_PREFIX" "$label"
}

cmd_list() {
  require_tmux
  tmux list-panes -s -F '#{pane_id} #{pane_title} #{pane_current_command}' \
    | awk -v p="$MGMT_PREFIX" 'index($2,p)==1'
}

cmd_send() {
  require_tmux
  local label="" keys=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --label) label="${2:-}"; shift 2;;
      --) shift; keys=("$@"); break;;
      -h|--help) usage; exit 0;;
      *) die "unknown flag: $1";;
    esac
  done
  [[ -n "$label" ]] || die "send requires --label <slug>"
  [[ ${#keys[@]} -gt 0 ]] || die "send requires -- <text>"
  local pid
  pid=$(panes_by_title "${MGMT_PREFIX}${label}")
  [[ -n "$pid" ]] || die "no pane with label '$label'"
  local text="${keys[*]}"
  tmux send-keys -t "$pid" -l -- "$text"
  tmux send-keys -t "$pid" Enter
}

cmd_capture() {
  require_tmux
  local label="" lines="$DEFAULT_CAPTURE_LINES"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --label) label="${2:-}"; shift 2;;
      --lines) lines="${2:-}"; shift 2;;
      -h|--help) usage; exit 0;;
      *) die "unknown flag: $1";;
    esac
  done
  [[ -n "$label" ]] || die "capture requires --label <slug>"
  local pid
  pid=$(panes_by_title "${MGMT_PREFIX}${label}")
  [[ -n "$pid" ]] || die "no pane with label '$label'"
  tmux capture-pane -p -t "$pid" -S "-$lines"
}

cmd_kill() {
  require_tmux
  local label=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --label) label="${2:-}"; shift 2;;
      -h|--help) usage; exit 0;;
      *) die "unknown flag: $1";;
    esac
  done
  [[ -n "$label" ]] || die "kill requires --label <slug>"
  local pid
  pid=$(panes_by_title "${MGMT_PREFIX}${label}")
  [[ -n "$pid" ]] || die "no pane with label '$label'"
  tmux kill-pane -t "$pid"
  rebalance_strip
}

verb="${1:-}"
[[ -n "$verb" ]] || { usage; exit 2; }
shift
case "$verb" in
  check-env) cmd_check_env "$@";;
  spawn)     cmd_spawn "$@";;
  list)      cmd_list "$@";;
  send)      cmd_send "$@";;
  capture)   cmd_capture "$@";;
  kill)      cmd_kill "$@";;
  -h|--help) usage; exit 0;;
  *) die "unknown verb: $verb (try --help)";;
esac
