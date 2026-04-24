# claude-tmux

A Claude Code skill that lets Claude put long-lived processes (dev servers, watchers, log tails) into a visible tmux pane below its own, instead of backgrounding them invisibly.

## Layout

```
+------------------+------------------+
| Claude           | nvim editor      |
|                  | (mgmt:editor)    |
+------------------+------------------+
| A   |   B   |   C  (full width)    |
+-------------------------------------+
        bottom strip (long-lived)
```

- **Bottom strip** — long-lived processes. First takes 25% of height (full window width); subsequent panes tile horizontally and re-equalize.
- **Edit mirror** — a persistent nvim on the right half of Claude's row, driven automatically by a `PostToolUse` hook: every file Claude edits is loaded as a new buffer. Reserved label `editor`.

## Install

Claude auto-discovers skills under `~/.claude/skills/`. Drop this directory there:

```sh
# From wherever you checked the skill out:
cp -R claude-tmux ~/.claude/skills/
chmod +x ~/.claude/skills/claude-tmux/scripts/tmux-pane.sh
```

Symlinking works too (`ln -s "$PWD/claude-tmux" ~/.claude/skills/`). Restart Claude after installing so the skill shows up in the in-session skill list.

Claude must be launched from inside a tmux session (`$TMUX` must be set). If not, the skill asks the user to either reopen Claude in tmux or proceed without the skill — it does not silently fall back.

### Sandbox note (Linux)

If you run Claude Code with `sandbox.enabled: true`, the helper's calls to tmux will fail with `error connecting to /tmp/tmux-<uid>/default (Operation not permitted)` because seccomp blocks Unix-socket connects by default. Add this to `~/.claude/settings.json` so spawn/list/send/capture/kill can reach the tmux server:

```json
"sandbox": {
  "network": { "allowAllUnixSockets": true }
}
```

On Linux, socket allowlisting by path isn't possible (seccomp can't filter `connect()` paths), so this is all-or-nothing. macOS users can use `sandbox.network.allowUnixSockets: ["/tmp/tmux-*/*"]` instead.

## Verbs

Run the helper as `~/.claude/skills/claude-tmux/scripts/tmux-pane.sh <verb>`.

| Verb | Usage | Purpose |
|---|---|---|
| `check-env` | — | Exit 0 if inside tmux. |
| `spawn` | `--label <slug> -- <cmd...>` | Start a long-lived process in the bottom strip (full width). |
| `edit-show` | `--file <path>` | Open `<path>` in the persistent right-side nvim (new buffer if it's already running). Driven by the `PostToolUse` hook. |
| `list` | — | Print managed panes (`mgmt:*`). |
| `send` | `--label <slug> -- <text>` | Send literal text + Enter to a pane. |
| `capture` | `--label <slug> [--lines N]` | Print last N lines of a pane (default 200). |
| `kill` | `--label <slug>` | Kill a pane; rebalance the strip. |

## PostToolUse hook

The edit mirror is wired up via `~/.claude/settings.json`:

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write|MultiEdit|NotebookEdit",
      "hooks": [
        { "type": "command", "command": "~/.claude/skills/claude-tmux/scripts/edit-hook.sh" }
      ]
    }
  ]
}
```

`edit-hook.sh` parses the tool JSON, resolves an absolute path, and calls `edit-show`. It always exits 0 and silently no-ops if `$TMUX` is unset, `nvim` is missing, or `jq` is missing — so edits are never blocked.

## Design notes

- **State lives in tmux.** Managed panes are identified by titles with prefix `mgmt:` (e.g. `mgmt:frontend`, `mgmt:api`). No sidecar state file — tmux is the source of truth.
- **`remain-on-exit on`** is set on every spawned pane so crashes stay visible for inspection via `capture`.
- **Layout math**: explicit `resize-pane -x` per pane after each spawn, rather than `select-layout`, to avoid disturbing Claude's own pane.
- **Out of scope**: nested tmux sessions; panes the user created outside this skill; short-lived commands that don't need to be visible (run those through plain Bash).
