# dotfiles

Personal dotfiles managed with [yadm](https://yadm.io) (Yet Another Dotfiles Manager).

## Tracked files

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh config — PATH, nvm, Claude Code safety-net env vars |
| `.tmux.conf` | tmux config — TPM plugins (tmux-sensible, tmux-which-key, tmux-hint) |
| `.claude/CLAUDE.md` | Global Claude Code instructions |
| `.claude/settings.json` | Claude Code settings — plugins, sandbox, permissions |
| `.claude/skills/` | Custom Claude Code skills |
| `.config/yadm/bootstrap` | Bootstrap script for a new machine |

## Bootstrap on a new machine

```sh
# 1. Install yadm
brew install yadm        # macOS
sudo apt install yadm    # Linux (Debian/Ubuntu)
# or: https://yadm.io/docs/install

# 2. Clone the repo (checks out files directly into $HOME)
yadm clone git@github.com:michaelsung/dotfiles.git

# 3. Run the bootstrap script
~/.config/yadm/bootstrap
```

The bootstrap script installs Claude Code plugins and configures the Playwright MCP server.

### Prerequisites

- [zsh](https://www.zsh.org/) — expected shell (set as default: `chsh -s $(which zsh)`)
- [Claude Code](https://claude.ai/code) (`npm install -g @anthropic-ai/claude-code`)
- [nvm](https://github.com/nvm-sh/nvm) (for Node version management; provides `node` and `npx`)
- [jq](https://jqlang.github.io/jq/) (`brew install jq` / `apt install jq`) — required by `.claude/statusline.sh` for JSON parsing
- [tmux](https://github.com/tmux/tmux) + [tpm](https://github.com/tmux-plugins/tpm) (for tmux plugins)
- [tmux-hint](https://github.com/michaelsung/tmux-hint) cloned to `~/projects/tmux-hint/`

## Adding new dotfiles

```sh
yadm add ~/.config/some/new/file
yadm commit -m "add: some/new/file"
yadm push
```

## Claude Code config changes

After editing any file under `.claude/`:

```sh
yadm add .claude/<file>
yadm commit -m "claude: <description>"
```
