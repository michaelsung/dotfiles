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

## TypeScript Checks
- Use `mcp__ide__getDiagnostics` (LSP) instead of `npx tsc --noEmit` to verify TypeScript correctness after edits

## Specs
- After writing a spec, always display the full content inline in the chat — never ask the user to open the file

## Plan Execution
- After writing a plan, skip "which approach?" and immediately invoke the `superpowers:subagent-driven-development` skill

## Dev Servers
- Tell the user to run `! <command>` in the prompt to start dev servers — do not use the Bash tool for this
