---
name: claude-tmux
description: Run processes in visible tmux panes alongside Claude's own pane, instead of blocking the shell or hiding output via run_in_background. Use `spawn` for long-lived processes the user will want to watch (dev servers, watchers, tail -f, docker logs) — these go in a bottom strip under Claude's pane. Use `oneshot` for short commands whose output is worth glancing at — these appear in a right-side rail that auto-closes 10 seconds after the command finishes. Trigger on phrases like "run the dev server", "start the backend", "spin up", "in the background but visibly", or any request to launch a process the user will want to see while Claude keeps working. Do NOT trigger for trivial reads Claude does itself (ls, grep, cat) or for build/test/lint runs where Claude needs the exit code synchronously.
tools: Bash
---

# claude-tmux

This skill lets Claude split its tmux window into purpose-specific panes so the user can *see* what Claude is running, instead of backgrounding processes where they'd be invisible.

Helper script: `~/.claude/skills/claude-tmux/scripts/tmux-pane.sh`

## Layout model

```
+----------------------+--------+
| Claude (top-left)    | one-   |
|                      | shot   |
+---+---+---+          | rail   |
| A | B | C |          | (auto  |
+---+---+---+----------+ closes)+
   bottom strip (long-lived)
```

- **Bottom strip** (25% tall, below Claude): one or more long-lived panes, tiled horizontally. Use `spawn`.
- **Right rail** (20% wide, full window height): a single transient pane for short commands. Use `oneshot`. Auto-closes 10s after the command finishes.

Pane identity is a slug (e.g. `frontend`, `api`) stored in the pane title as `mgmt:<slug>`. The rail uses the reserved slug `oneshot`.

## Preflight

Before the first use in a session, check tmux is available:

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh check-env

If it exits non-zero, this skill cannot run (Claude was launched outside tmux). **Stop and ask the user** (via `AskUserQuestion` if available, otherwise a plain question) to choose between:

1. **Reopen Claude inside tmux** — they exit this session, run `tmux new -s claude` (or attach to an existing session), and relaunch `claude` from inside it. Subsequent invocations of this skill will work.
2. **Proceed without this skill** — fall back to the Bash tool's `run_in_background: true` for the current request. Mention that output won't be visible in a pane.

Do not silently degrade. Wait for the user's answer before continuing.

## spawn — long-lived processes

Use for processes the user will want to watch over time. Dev servers, file watchers, `tail -f`, `docker logs -f`, message consumers, anything that's meant to keep running.

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh spawn --label frontend -- 'npm run dev'
    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh spawn --label api -- 'cargo run'
    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh spawn --label worker -- 'node worker.js'

First call: splits 25% off the bottom of Claude's pane. Subsequent calls: split the strip horizontally and equalize widths. Focus returns to Claude's pane after each call.

**Slug conventions**: short, kebab-case, role-based (`frontend`, `api`, `worker`, `logs`, `db-shell`). One pane per slug — attempts to reuse a slug fail; `kill` it first.

**Exit behavior**: Panes set `remain-on-exit on`, so when the process dies the pane stays with its output visible. This is deliberate — you can `capture` the crash. Use `kill` to remove the pane.

## oneshot — short visible commands

Use for commands that run in seconds-to-tens-of-seconds and whose output is worth showing: running a user-written script, probing a service, verifying a config change.

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh oneshot -- 'curl -s localhost:3000/health | jq .'
    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh oneshot -- 'bash run-integration-tests.sh'

The rail is recycled — a new `oneshot` kills any existing rail pane first. The pane auto-closes 10s after the command finishes.

**Do NOT use `oneshot` for**:
- Commands Claude needs the exit code or output of programmatically (builds, tests, lints, greps) — use plain Bash so the result comes back to Claude.
- Trivial reads Claude is doing (`ls`, `cat`, version checks) — they clutter the rail.

## Interacting with managed panes

List all managed panes (pane_id, title, running command):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh list

Capture recent output from a pane (default 200 lines):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh capture --label api --lines 80

Send a line of input (appends Enter automatically):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh send --label api -- 'reload'

Kill a pane (bottom-strip panes re-equalize afterward):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh kill --label api

For special keys (Ctrl-C, arrow keys), use `tmux send-keys` directly with a pane_id from `list`:

    tmux send-keys -t %42 C-c

## Common patterns

**Single dev server, then verify it came up:**

    spawn --label dev -- 'npm run dev'
    # wait ~2s for bind
    capture --label dev --lines 40

**Frontend + backend + a quick health probe:**

    spawn --label web -- 'npm run dev'
    spawn --label api -- 'uvicorn app:app --reload'
    # ...after giving them a moment to start...
    oneshot -- 'curl -s localhost:8000/health && echo && curl -sI localhost:3000'

**Interactive shell pane for ad-hoc commands:**

    spawn --label shell -- bash
    send --label shell -- 'echo hello'
    capture --label shell --lines 5

## Limitations

- Requires Claude to be launched inside a tmux session (`$TMUX` must be set).
- Beyond ~4 panes in the bottom strip, output becomes hard to read — prefer consolidating logs.
- Terminal resize during a session doesn't re-equalize the strip automatically; the next `spawn` or `kill` rebalances.
- `send` sends literal text + Enter. For programs needing special keys, use `tmux send-keys` with the pane_id.
- Nested tmux sessions are not supported.
- The skill manages only panes it created (title prefix `mgmt:`); user-created panes are untouched.
