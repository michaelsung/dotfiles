---
name: git-commit
description: Analyze unstaged/untracked changes, group them into logically separate commits, and commit each group with a Conventional Commits message. Use this skill whenever the user wants to commit their work — "commit my changes", "commit everything", "create commits", "stage and commit", or just "done, commit this". Also trigger when the user finishes a session and wants to wrap up with git commits, even if they phrase it casually. Do NOT trigger when changes are already staged and the user only wants a commit message written — that's a simpler task that doesn't need this skill.
---

# Smart Git Commit

Your job is to turn all current unstaged and untracked changes into a well-organized sequence of commits, each following the Conventional Commits standard. Splitting is at the **file level only** — never attempt partial-file staging. Work autonomously — don't ask for approval before committing. Never ask about pushing.

## Step 1: Read the full workspace state

Run these in parallel:

```bash
git status --short
git diff HEAD
git diff --cached
git log --oneline -5
```

From `git status`, note any untracked files that should be committed (new files not yet tracked).

## Step 2: Analyze and group changes

Read the full diff. Group files into logical commits — each commit should represent one coherent intent.

**What belongs in one commit:**
- A new feature and the types/interfaces it introduces
- A bug fix and any test that covers it
- A refactor of one module (even across several files)
- A dependency update and its resulting lockfile change
- A config change and the feature it enables

**What should be separate commits:**
- Unrelated bug fixes
- A refactor that precedes a feature built on top of it
- Changes to different subsystems with no logical link

**Files with mixed changes:** If a single file contains changes that span multiple logical intents, assign it to whichever commit it fits best and use a comma-separated commit message to capture all the intents — do not attempt to split the file. See the commit message section for how to handle the type and description in this case.

**How to order commits:** Each commit should stand alone without depending on a later one. Generally: foundational changes first (new shared types, utilities, config), then features that use them, then tests, then docs.

## Step 3: Stage and commit each group

Work through your plan in order. For each commit:

```bash
git add path/to/file1 path/to/file2   # stage the files for this commit
git commit -m "<message>"
git show --stat HEAD                   # verify it looks right
```

For untracked files, `git add` works the same way.

## Conventional Commits format

```
<type>[(<scope>)]: <description>
```

**Types:**

| Type | Use when |
|------|----------|
| `feat` | New capability or behavior visible to users/callers |
| `fix` | Corrects a bug |
| `refactor` | Restructures code without changing behavior |
| `perf` | Improves performance |
| `test` | Adds or corrects tests |
| `docs` | Documentation only |
| `style` | Whitespace, formatting — no logic change |
| `build` | Build system, bundler, compilation |
| `ci` | CI/CD pipeline config |
| `chore` | Tooling, maintenance, dependency bumps |
| `revert` | Reverts a previous commit |

**Scope:** A short noun identifying the area of the codebase — typically a module, package, component, or feature name. Infer from the files changed (e.g., `src/auth/` → `auth`, `components/Button.tsx` → `ui/button`). Omit only when a commit genuinely spans the entire codebase.

**Description:** Imperative present tense, lowercase, no trailing period.

Examples:
- `feat(auth): add OAuth2 PKCE flow`
- `fix(cart): prevent double-submission on slow networks`
- `refactor(db): extract query builder into separate module`
- `chore(deps): upgrade vitest to v2`

**Breaking changes:** Append `!` after type/scope: `feat(api)!: remove deprecated v1 endpoints`

**Mixed-change files:** When a commit includes a file with multiple unrelated intents, write a comma-separated description and use the single most important type across all the changes. Type importance order (highest to lowest): `feat` > `fix` > `refactor` > `perf` > `test` > `docs` > `style` > `build` > `ci` > `chore`.

For example, if a file adds new functionality, fixes a race condition, and renames some constants:
```
feat(auth): add refresh token support, fix race condition on expiry, rename TOKEN_TTL constants
```

The scope should reflect the dominant area of the file. If the mixed changes truly span unrelated areas with no single dominant scope, omit the scope.

## After all commits

Verify everything was committed:

```bash
git diff HEAD        # should be empty
git status           # should show nothing uncommitted
```

If any changes remain uncommitted, report them to the user rather than silently leaving them behind.

Then show a summary:

```bash
git log --oneline HEAD~<N>..HEAD
```

Do not ask about pushing — the user will handle that manually.

## Common edge cases

- **Lockfiles** (package-lock.json, yarn.lock, Cargo.lock): commit with the manifest change that caused them
- **Generated files**: commit with the source that generates them
- **Config enabling a new feature**: commit with the feature, not as a separate `chore:`
- **Already-staged changes**: incorporate them into your plan. If they don't fit cleanly into the logical grouping, `git reset HEAD` to unstage them first, then re-stage as part of the correct commit
