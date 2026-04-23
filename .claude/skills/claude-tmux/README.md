# claude-tmux

A Claude Code skill that lets Claude put long-lived processes (dev servers, watchers, log tails) into a visible tmux pane below its own, instead of backgrounding them invisibly.

## Layout

```
+-------------------------------+
| Claude (top)                  |
|                               |
+---+---+---+-------------------+
| A | B | C |
+---+---+---+
   bottom strip (long-lived)
```

- **Bottom strip** — long-lived processes. First takes 25% of height; subsequent panes tile horizontally and re-equalize.

## Install

From inside this repo:

```sh
ln -s "$PWD" ~/.claude/skills/claude-tmux
chmod +x scripts/tmux-pane.sh
```

Or copy instead of symlink if you prefer. Claude auto-discovers skills under `~/.claude/skills/`; no further registration needed. Restart Claude after installing so the skill shows up in the in-session skill list.

Claude must be launched from inside a tmux session (`$TMUX` must be set). If not, the skill asks the user to either reopen Claude in tmux or proceed without the skill — it does not silently fall back.

## Verbs

Run the helper as `~/.claude/skills/claude-tmux/scripts/tmux-pane.sh <verb>`.

| Verb | Usage | Purpose |
|---|---|---|
| `check-env` | — | Exit 0 if inside tmux. |
| `spawn` | `--label <slug> -- <cmd...>` | Start a long-lived process in the bottom strip. |
| `list` | — | Print managed panes (`mgmt:*`). |
| `send` | `--label <slug> -- <text>` | Send literal text + Enter to a pane. |
| `capture` | `--label <slug> [--lines N]` | Print last N lines of a pane (default 200). |
| `kill` | `--label <slug>` | Kill a pane; rebalance the strip. |

## Design notes

- **State lives in tmux.** Managed panes are identified by titles with prefix `mgmt:` (e.g. `mgmt:frontend`, `mgmt:api`). No sidecar state file — tmux is the source of truth.
- **`remain-on-exit on`** is set on every spawned pane so crashes stay visible for inspection via `capture`.
- **Layout math**: explicit `resize-pane -x` per pane after each spawn, rather than `select-layout`, to avoid disturbing Claude's own pane.
- **Out of scope**: nested tmux sessions; panes the user created outside this skill; short-lived commands that don't need to be visible (run those through plain Bash).
