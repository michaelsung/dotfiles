# Global Claude Code Config

## Dotfiles
All Claude Code config is tracked in yadm. After adding/editing config files:
`yadm add <file> && yadm commit -m "claude: <description>"`

@~/.config/yadm/CLAUDE.md

## Safety Rules (enforced by safety-net + hookify plugins)
- Never `git reset --hard`, `git push --force`, or `git stash clear` without explicit confirmation
- Never `rm -rf` outside the current working directory
- For unattended runs: surface filesystem/permission blockers rather than working around them

## Documentation Maintenance
- Use the `update-docs` skill to update README and other repo docs
- Run `/revise-claude-md` at session end when project patterns were discovered
- Run `claude-md-improver` skill periodically to audit CLAUDE.md quality

## MCP
- **playwright**: Available for browser automation, web scraping, and UI testing
