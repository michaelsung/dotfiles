---
name: consolidate-memories
description: Promotes durable user and feedback memories from all projects into ~/.claude/CLAUDE.md. Use when you want to sync machine-local memories to global CLAUDE.md, or when the user says "consolidate memories", "promote memories", "sync memories to CLAUDE.md", or runs /consolidate-memories.
---

# Consolidate Memories

Scan all project memory files, identify `user` and `feedback` entries not already covered by `~/.claude/CLAUDE.md`, and offer to append them.

## Step 1: Discover memory files

Use Glob to find all memory files:
- Pattern: `~/.claude/projects/*/memory/*.md`
- Exclude any file named `MEMORY.md`

Read each matching file. Parse the frontmatter (between `---` delimiters). Keep only files where `type` is `user` or `feedback`.

## Step 2: Read global CLAUDE.md

Read `~/.claude/CLAUDE.md` in full. This is the dedup baseline.

## Step 3: Dedup analysis

For each candidate memory file, judge whether its substance is already covered in CLAUDE.md.

**Covered** means the same rule, preference, or fact is already expressed — even if worded differently:
- Memory: "never commit without asking" / CLAUDE.md: "only commit when user explicitly requests" → **skip**
- Memory: "user is a senior Go engineer" / CLAUDE.md already has this → **skip**

**Not covered** means the CLAUDE.md has nothing expressing this:
- Memory: "user prefers single bundled PRs for refactors" / CLAUDE.md has no PR strategy → **include**
- Memory: "don't mock the database in tests" / CLAUDE.md has nothing about testing → **include**

Build a list of genuinely new items only.

## Step 4: Present candidates

If no new items found, say:
> "No new items to promote — ~/.claude/CLAUDE.md already covers everything in your memory files."
And stop.

Otherwise present:

```
Found N items not already covered by ~/.claude/CLAUDE.md:

1. [<type>] <memory name>
   Source: <file path>
   Content: <body of the memory, trimmed to 2-3 lines>
   Why: <one-line rationale for why it's not covered>

2. ...

Apply all? (yes / skip <numbers> e.g. "skip 2 3" / no)
```

## Step 5: Apply approved items

Wait for user response.

- **"yes"** — apply all items
- **"skip 1 3"** (or similar) — apply all except those numbers
- **"no"** — stop, apply nothing

For each approved item, append to `~/.claude/CLAUDE.md` using the Edit tool. Format each addition as a concise line or short block matching the existing style of CLAUDE.md. Do not add section headers unless CLAUDE.md already uses them.

After writing, confirm: "Added N item(s) to ~/.claude/CLAUDE.md."
