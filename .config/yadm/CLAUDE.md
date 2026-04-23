# Dotfiles repo (yadm)

This repo is managed with **yadm** — the working tree is `$HOME`, not a project subdirectory.

## Key facts

- Remote: `git@github.com:michaelsung/dotfiles.git`
- All yadm commands substitute for `git` (e.g. `yadm add`, `yadm commit`, `yadm push`)
- Never run plain `git` commands in `$HOME` — they will target the wrong repo

## Workflow

```sh
# Stage and commit a tracked file
yadm add ~/.claude/settings.json
yadm commit -m "claude: <description>"

# Check what's tracked / staged
yadm status
yadm list
```

## Commit conventions

| Prefix | Use for |
|--------|---------|
| `claude:` | `.claude/` files (settings, skills, CLAUDE.md) |
| `zsh:` | `.zshrc` |
| `tmux:` | `.tmux.conf` |
| `yadm:` | `.config/yadm/bootstrap`, this file |
| `add:` | First commit of a newly tracked file |

## Bootstrap

The bootstrap script lives at `~/.config/yadm/bootstrap`. It is idempotent — safe to re-run. It installs:

- Claude Code plugin marketplaces (`anthropics/claude-plugins-official`, `kenryu42/cc-marketplace`)
- Plugins: `safety-net`, `claude-md-management`, `frontend-design`, `context7`, `code-simplifier`, `skill-creator`, `security-guidance`

## What is NOT tracked by yadm

- `~/.claude.json` (Claude Code user-scope MCP config — machine-local)
- `~/.nvm/` (managed by nvm installer)
- `~/.tmux/plugins/` (managed by tpm)
- SSH keys, credentials, secrets
