# Global Claude Code Config

## Dotfiles
All Claude Code config is tracked in yadm. After adding/editing config files:
`yadm add <file> && yadm commit -m "claude: <description>"`

@~/.config/yadm/CLAUDE.md

## Safety Rules (enforced by safety-net plugin)
- Never `git reset --hard`, `git push --force`, or `git stash clear` without explicit confirmation
- Never `rm -rf` outside the current working directory
- For unattended runs: surface filesystem/permission blockers rather than working around them

## MCP
- **context7**: Prefer over WebFetch for library/framework/SDK documentation lookups

## Specs
- After writing a spec, always display the full content inline in the chat — never ask the user to open the file

## Generic Working Directory
- `~/projects/claude-generic-working-dir` is a scratch space for adjusting Claude Code settings or dotfile config
- Use it when files need to be created outside of a temp directory
