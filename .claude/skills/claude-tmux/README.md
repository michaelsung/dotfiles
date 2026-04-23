# claude-tmux

A Claude Code skill that lets Claude split its tmux window into visible panes for long-lived processes (dev servers) and short one-shot commands, instead of backgrounding them invisibly.

## Layout

```
+----------------------+--------+
| Claude (top-left)    | one-   |
|                      | shot   |
+---+---+---+          | rail   |
| A | B | C |          | (auto  |
+---+---+---+----------+ closes)+
   bottom strip (long-lived)
```

- **Bottom strip** — long-lived processes. First takes 25% of height; subsequent panes tile horizontally.
- **Right rail** — short commands. 20% width, full height. Auto-closes 10s after the command exits.

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
| `oneshot` | `-- <cmd...>` | Run a short command in the right rail; auto-closes after 10s. |
| `list` | — | Print managed panes (`mgmt:*`). |
| `send` | `--label <slug> -- <text>` | Send literal text + Enter to a pane. |
| `capture` | `--label <slug> [--lines N]` | Print last N lines of a pane (default 200). |
| `kill` | `--label <slug>` | Kill a pane; rebalance the strip. |

## Design notes

- **State lives in tmux.** Managed panes are identified by titles with prefix `mgmt:` (e.g. `mgmt:frontend`, `mgmt:oneshot`). No sidecar state file — tmux is the source of truth.
- **`remain-on-exit on`** is set on long-lived panes so crashes stay visible; `oneshot` panes self-close after a 10s grace period.
- **Layout math**: explicit `resize-pane -x` per pane after each spawn, rather than `select-layout`, to avoid disturbing Claude's own pane.
- **Out of scope**: nested tmux sessions; panes the user created outside this skill.
