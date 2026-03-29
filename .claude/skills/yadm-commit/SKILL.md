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

Categorize findings:
- **Modified tracked files** (`M` in status) — need to be committed
- **Deleted tracked files** (`D` in status) — need to be committed (removal)
- **Untracked files** (`?` in status) — candidates for first-time tracking; must be vetted before adding
- **Already-staged changes** — incorporate into your plan

---

## Step 2: Vet untracked files before adding

For every untracked file, assess whether it is safe to track in a **public** GitHub repo:

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

**If any hits are found:**
- Show the user exactly which files and lines triggered the match
- Do NOT push
- Advise how to remediate: either remove the file from tracking (`yadm rm --cached <file>`) or redact the sensitive value
- Add the file to `~/.gitignore_global` or a yadm-specific exclude

**If the audit is clean:** confirm "Audit passed — no secrets detected in tracked files."

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
