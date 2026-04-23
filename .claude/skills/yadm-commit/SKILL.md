---
name: yadm-commit
description: Commit dotfile changes into the yadm repo. Stages new files (with safety vetting), commits modified tracked files using the correct prefix convention, then audits the full yadm repo for secrets before offering to push to the public GitHub remote. Trigger when the user says "commit dotfiles", "yadm commit", "save my dotfiles", or finishes a session involving dotfile/config edits.
tools: Bash, Read, Grep
---

# yadm-commit

Commit all pending dotfile changes into yadm, then audit the repo for anything that must not be pushed to a public GitHub repo.

**Key constraint:** Always use `yadm` — never `git` — for all repo operations. The working tree is `$HOME`.

---

## Step 1: Assess current state

Run in parallel:

```bash
yadm status --short
yadm list
yadm log --oneline -5
```

**Important:** yadm sets `status.showUntrackedFiles=no` by default because the working tree is `$HOME` — `yadm status` will never show `?` untracked files. Only modified (`M`) and deleted (`D`) tracked files appear. New files must be discovered separately in Step 2.

Categorize status findings:
- **Modified tracked files** (`M`) — need to be committed
- **Deleted tracked files** (`D`) — need to be committed (removal)
- **Already-staged changes** — incorporate into your plan

---

## Step 2: Discover and vet new untracked files

Since `yadm status` does not reveal untracked files, discover candidates by comparing known dotfile locations against the `yadm list` output.

**Get the list of already-tracked files:**
```bash
yadm list
```

**Scan known dotfile directories for files not yet tracked:**
```bash
# Check top-level dotfiles
ls -a ~ | grep '^\.' | grep -v '^\.\.$'

# Check common config dirs that may have new files
find ~/.claude -type f 2>/dev/null
find ~/.config/yadm -type f 2>/dev/null
# Add other dirs relevant to what was created this session
```

Compare findings against `yadm list`. Any file present on disk but absent from `yadm list` is a candidate for first-time tracking.

**Focus on files created or edited during the current session** — if the user or Claude created new config files (e.g., a new skill, a new tool config), those are the primary candidates. Do not trawl all of `$HOME`.

**Vet each candidate before adding.** Assess whether it is safe to track in a **public** GitHub repo:

**Reject immediately (do not add, warn the user):**
- Anything under `~/.ssh/`, `~/.gnupg/`, `~/.aws/`, `~/.config/gcloud/`
- Files with `.pem`, `.key`, `.p12`, `.pfx`, `.cer`, `.crt` extensions
- Files containing tokens/credentials: scan with a grep for patterns like `PRIVATE KEY`, `api_key`, `token`, `password`, `secret`, `aws_access`, `client_secret` (case-insensitive)
- `.env` files, `*.env`, `credentials`, `secrets.*`

**Require explicit user confirmation before adding:**
- Any file not obviously a dotfile/config (e.g., something in an unexpected location)

**Safe to add (proceed):**
- Shell configs: `.zshrc`, `.bashrc`, `.bash_profile`, `.profile`
- Editor configs: `.vimrc`, `.config/nvim/**`, `.config/helix/**`
- Terminal/multiplexer configs: `.tmux.conf`, `.config/alacritty/**`, `.config/kitty/**`, `.config/wezterm/**`
- Tool configs: `.gitconfig`, `.gitignore_global`, `.config/starship.toml`, `.config/yadm/**`
- Claude Code configs: `.claude/**` (excluding any file containing secrets)
- Other dotfiles with no sensitive content

For borderline files, read their contents before deciding.

---

## Step 3: Commit modified tracked files

Group modified files into logical commits based on which tool/area they belong to. For each commit:

```bash
yadm add path/to/file
yadm commit -m "<prefix>: <description>"
yadm show --stat HEAD
```

### Commit prefix conventions

| Prefix | Files |
|--------|-------|
| `claude:` | `.claude/**` — settings, skills, CLAUDE.md |
| `zsh:` | `.zshrc`, `.bash_profile`, `.bashrc` |
| `tmux:` | `.tmux.conf`, `.tmux/**` |
| `yadm:` | `.config/yadm/bootstrap`, `.config/yadm/CLAUDE.md` |
| `vim:` / `nvim:` | `.vimrc`, `.config/nvim/**` |
| `git:` | `.gitconfig`, `.gitignore_global` |
| `add:` | **First-time** tracking of any new file |
| `dotfiles:` | Changes spanning multiple unrelated areas |

For **new files** being tracked for the first time, always use `add:` as the prefix regardless of the file type:
```
add: track <filename>
```

---

## Step 4: Security audit of entire yadm repo

Before offering to push, scan every tracked file for sensitive content.

```bash
yadm list
```

Then for each tracked file, check for secret patterns. Run a combined scan:

```bash
yadm list | xargs -I{} grep -l -i \
  -e "PRIVATE KEY" \
  -e "BEGIN RSA" \
  -e "BEGIN EC" \
  -e "BEGIN OPENSSH" \
  -e "api_key\s*=" \
  -e "api_secret\s*=" \
  -e "client_secret" \
  -e "access_token" \
  -e "auth_token" \
  -e "password\s*=" \
  -e "AWS_SECRET" \
  -e "GITHUB_TOKEN" \
  -e "ANTHROPIC_API_KEY" \
  -- "$HOME/{}" 2>/dev/null || true
```

Also check for files that should never be in a public repo:
```bash
yadm list | grep -i -e "\.pem$" -e "\.key$" -e "\.p12$" -e "id_rsa" -e "id_ed25519" -e "\.env$" -e "credentials$" -e "secrets\."
```

**Audit tracked `.claude/` files specifically.** The `.claude/` tree mixes intentionally-tracked config (settings, skills, CLAUDE.md) with machine-local state that must never be pushed to a public repo. Run:

```bash
yadm list | grep '^\.claude/'
```

Flag any match against these patterns as a blocker — they contain auth tokens, conversation transcripts, or machine-local runtime state:

| Pattern | Why it must not be tracked |
|---------|----------------------------|
| `.claude/.credentials.json` | OAuth/API credentials |
| `.claude.json` | User-scope MCP config, may contain API keys — explicitly excluded per `~/.config/yadm/CLAUDE.md` |
| `.claude/projects/**` | Full conversation transcripts — private, may contain secrets pasted into prompts |
| `.claude/todos/**` | Session task state with conversation context |
| `.claude/shell-snapshots/**` | Captured shell env, may include exported secrets |
| `.claude/history.jsonl` (or `*history*`) | Prompt history |
| `.claude/statsig/**` | Telemetry/session identifiers |
| `.claude/ide/**` | IDE session lockfiles |
| `.claude/debug/**`, `.claude/logs/**` | Runtime logs |
| `.claude/__store.db*` | Local state DB |

Intentionally-tracked `.claude/` paths are limited to: `settings.json`, `CLAUDE.md`, `commands/**`, `skills/**`, `agents/**`, `hooks/**`, `output-styles/**`, `plugins/config.json`, `keybindings.json`. Anything else under `.claude/` should be justified before tracking.

If a flagged file is found, halt and advise:
```bash
yadm rm --cached <path>
echo "<path>" >> ~/.config/yadm/gitignore   # or ~/.gitignore_global
```

Also scan for any information that would be undesirable in a public repository. The main risks in dotfiles are:
- **Hardcoded absolute paths** revealing the local username (e.g. `/Users/yourname/`, `/home/yourname/`)
- **Hostnames / device names** (e.g. `MacBook-Pro-3.local`, output of `hostname`)
- **Real contact info** accidentally pasted into a config (full name, phone number, street address)

Run a targeted scan using the actual username and hostname:

```bash
UNAME=$(whoami)
HNAME=$(hostname)
yadm list | xargs -I{} grep -l \
  -e "/Users/$UNAME/" \
  -e "/home/$UNAME/" \
  -e "$HNAME" \
  -- "$HOME/{}" 2>/dev/null || true
```

For any hits, read the flagged lines. Hardcoded paths and hostnames in dotfiles are often intentional (e.g. a machine-specific config) — confirm with the user before treating them as blockers. Only halt the push if the content is clearly sensitive (e.g. a real phone number or street address accidentally pasted in).

**If any hits are found:**
- Show the user exactly which files and lines triggered the match
- Do NOT push
- Advise how to remediate: either remove the file from tracking (`yadm rm --cached <file>`) or redact the sensitive value
- Add the file to `~/.gitignore_global` or a yadm-specific exclude

**If the audit is clean:** confirm "Audit passed — no secrets or PII detected in tracked files."

---

## Step 5: Final state and push offer

```bash
yadm status          # should be clean
yadm log --oneline origin/master..HEAD
```

Report how many commits are unpushed and their messages. Then ask:

> "N commits ready to push to `origin/master` (public: `git@github.com:michaelsung/dotfiles.git`). Push?"

Only push if the user explicitly confirms:
```bash
yadm push
```

---

## Edge cases

- **Deleted tracked files:** stage with `yadm rm <file>` and commit with the appropriate prefix + description `remove <filename>`
- **Renamed files:** stage both sides, commit as `yadm mv` where possible
- **`.claude/plugins/`:** Track plugin config files but be alert to any plugin that auto-writes secrets or tokens into its config dir
- **`settings.json`:** Safe to track but scan for any injected API keys before committing
- **Mixed-area changes in one file:** assign to the dominant area's prefix, note the secondary change in the description
