---
name: update-docs
description: Update repository documentation (README.md, docs/, CHANGELOG, API docs) to reflect current codebase state. Trigger when user says "update docs", "refresh the README", "sync docs", or "document recent changes".
tools: Read, Glob, Grep, Bash, Edit
---

Audit and update repository documentation to match current codebase state.

## Phase 1: Discover docs

Find documentation files (excluding node_modules, .git, vendor):
- README.md, CHANGELOG.md, CONTRIBUTING.md
- docs/**/*.md, doc/**/*.md, documentation/**/*.md

## Phase 2: Gather codebase facts

Cross-check against:
- package.json / pyproject.toml / Cargo.toml — version, description, scripts
- Recent git log (last 30 days) to understand what changed
- Actual directory structure vs. any directory tree in docs

## Phase 3: Audit each doc

| Area | Check |
|------|-------|
| Installation | Matches current package manager / lockfile? |
| Usage examples | APIs still valid? Code snippets still work? |
| Feature list | New features missing? Removed features still listed? |
| Config options | Match current code? |
| Prerequisites | Version requirements still accurate? |
| CLI flags | Match `--help` output? |
| Env vars | All documented? Check for new `process.env` / `os.environ` uses |

## Phase 4: Apply changes directly

Apply all identified updates without asking for confirmation. Sandbox + safety-net provide the safety backstop.

After applying: run `git diff` and summarize what changed.
