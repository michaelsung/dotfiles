---
name: claude-tmux
description: Spawn, inspect, or stop long-lived processes in visible tmux panes below Claude's own pane, instead of blocking the shell or hiding output via run_in_background. SPAWN for dev servers, file watchers, tail -f, docker logs -f, message consumers — anything the user will want to watch over time (trigger phrases like "run the dev server", "start the backend", "spin up", "start it in the background but visibly"). INSPECT (via list + capture) when the user references or reports issues with something already running in a pane — they're pointing Claude at output that's visible to them but not in the conversation (trigger phrases like "check the [X] pane", "what's in the tmux pane", "errors in the panes", "the dev server is failing", "getting issues from my dev server"). STOP/KILL (via kill) when the user wants to shut down something running in a managed pane (trigger phrases like "stop the dev server", "stop the dev servers", "kill the [X] pane", "shut down the backend", "stop it", "tear down the panes") — use the skill's `kill` verb rather than sending Ctrl-C via raw tmux. Do NOT trigger for build/test/lint runs where Claude needs the exit code synchronously, or for trivial reads Claude does itself (ls, grep, cat).
tools: Bash
---

# claude-tmux

This skill lets Claude put long-lived processes into a tmux pane below its own, so the user can *see* what's running instead of it being invisible in the background.

Helper script: `~/.claude/skills/claude-tmux/scripts/tmux-pane.sh`

## Layout model

```
+------------------+------------------+
| Claude           | nvim editor      |
|                  | (mgmt:editor)    |
+------------------+------------------+
| A   |   B   |   C  (full width)    |
+-------------------------------------+
        bottom strip (long-lived)
```

- **Bottom strip** — long-lived processes. First `spawn` takes 25% of height off the window (full width, via `-f`); subsequent `spawn`s split the strip horizontally and equalize widths. Always spans the full window width, regardless of whether the editor pane is open.
- **Editor mirror** — a single persistent nvim pane on the right side of Claude's row (40% width), labeled `mgmt:editor`. Driven automatically by the `PostToolUse` hook; reserved slug. Each edit scrolls the buffer to the changed region.

Pane identity is a slug (e.g. `frontend`, `api`) stored in the pane title as `mgmt:<slug>`. The slug `editor` is reserved.

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

## Interacting with managed panes

List all managed panes (pane_id, title, running command):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh list

Capture recent output from a pane (default 200 lines):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh capture --label api --lines 80

Send a line of input (appends Enter automatically):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh send --label api -- 'reload'

Kill a pane (remaining strip panes re-equalize afterward):

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh kill --label api

For special keys (Ctrl-C, arrow keys), use `tmux send-keys` directly with a pane_id from `list`:

    tmux send-keys -t %42 C-c

## Edit mirror (automatic)

After every `Edit`, `Write`, `MultiEdit`, or `NotebookEdit` tool call, a `PostToolUse` hook (`scripts/edit-hook.sh`) calls:

    ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh edit-show --file <abs-path> [--start <s> --end <e>]

The hook picks a text anchor for the edit (for `Edit` / `MultiEdit`, the longest non-blank line from the first 30 lines of `new_string` — longer lines are more likely to be unique), searches the post-edit file for it, and derives the edited line range by combining the anchor's position in the file with its offset inside `new_string` and the total new line count.

Behavior:

- First edit: splits Claude's pane vertically (right 40%) and launches `nvim --listen <sock> -c '<s>mark a' -c '<e>mark b' -c '<s>' -c 'normal! zz' -- <file>`. Marks `a` and `b` bracket the edited range; cursor lands on the start line, centered. Pane title becomes `mgmt:editor`.
- Subsequent edits: `nvim --server <sock> --remote <file>` switches to the buffer, `:checktime` reloads from disk (buffers would otherwise go stale after an Edit/Write), then `:<s>mark a<CR>:<e>mark b<CR>:<s><CR>zz` re-sets the marks, jumps, and centers. `:ls` inside nvim shows the history of edited files; ``'a``/``'b`` (or `` `a ``/`` `b ``) jump back to the edit range.
- When the range can't be resolved (deletion with empty `new_string`, or anchor not found), the range flags are omitted and the buffer opens without scrolling or setting marks.
- Closing nvim (`:q`) removes the pane; the next edit re-creates it cleanly.
- Silent no-op when: not in tmux, `nvim` missing, or `jq` missing. The hook always exits 0 so it can never block an edit.

Socket path: `${XDG_RUNTIME_DIR:-/tmp}/claude-nvim-<tmux-server-pid>.sock` (unique per tmux server).

You normally don't invoke `edit-show` directly — the hook handles it. If you need to force-refresh or open a file in the mirror manually, calling the verb is safe.

## Common patterns

**Single dev server, then verify it came up:**

    spawn --label dev -- 'npm run dev'
    # wait ~2s for bind
    capture --label dev --lines 40

**Frontend + backend running side by side:**

    spawn --label web -- 'npm run dev'
    spawn --label api -- 'uvicorn app:app --reload'

**Interactive shell pane for ad-hoc commands:**

    spawn --label shell -- bash
    send --label shell -- 'echo hello'
    capture --label shell --lines 5

**User reports issues in a pane Claude can't see directly:**

When the user says things like "I'm seeing errors in the panes", "the dev server is failing", or "check the [X] pane", inspect via `list` + `capture` rather than asking them to paste output.

    list                               # see what's running and their slugs
    capture --label api --lines 80     # read recent output from the relevant pane(s)

**User asks to stop/kill managed panes:**

When the user says "stop the dev servers", "kill the [X] pane", "shut down the backend", or similar, use `kill` — don't send Ctrl-C via raw tmux. `kill` both signals the process and removes the pane (re-equalizing the strip). Start with `list` if you don't already know the slugs.

    list                               # discover slugs if needed
    kill --label api
    kill --label web

## Limitations

- Requires Claude to be launched inside a tmux session (`$TMUX` must be set).
- Beyond ~4 panes in the bottom strip, output becomes hard to read — prefer consolidating logs.
- Terminal resize during a session doesn't re-equalize the strip automatically; the next `spawn` or `kill` rebalances.
- `send` sends literal text + Enter. For programs needing special keys, use `tmux send-keys` with the pane_id.
- Nested tmux sessions are not supported.
- The skill manages only panes it created (title prefix `mgmt:`); user-created panes are untouched.
