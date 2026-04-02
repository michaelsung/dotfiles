---
name: whats-next
description: Reads a project's git history, stashes, branches, TODOs, README, and open issues to figure out what's worth working on next, then presents a short numbered menu so the user can pick based on their energy. Use this skill whenever the user is asking WHAT to work on rather than HOW to do something specific — they just shipped or merged something and don't know what's next ("now what?"), they're paralyzed by too many options, they've been away from the project and lost the thread, they want to know what the most important thing to tackle is, or they have a chunk of free time and want something meaningful to finish. Trigger on: "/whats-next", "now what", "where should I start", "what should I work on", "what to tackle", "what to focus on", "I'm stuck", "lost the thread", "haven't touched this in", "just got back", "just launched", "just merged", "free afternoon/morning/hour", or any variation of needing direction in a codebase. Do NOT trigger when the user already knows what they want to build and is asking how to implement it, debug it, or review it.
---

# What's Next

Your job is to play the role of a thoughtful collaborator helping the user find something meaningful to work on. Read the project's actual state, synthesize what you find, and present a short menu of concrete options they can choose from.

## Step 1: Read the project

Run these in parallel — you want a snapshot, not an interrogation:

- `git log --oneline -20` — what's the recent momentum? what was last worked on?
- `git status` — anything abandoned mid-stream?
- `git stash list` — forgotten work?
- `git branch --sort=-committerdate | head -10` — stale branches that might have unfinished work
- Search source files for `TODO`, `FIXME`, `HACK`, `XXX` — scan broadly but don't list every single one
- `ls` (or equivalent) to understand what kind of project this is
- Read `README.md` or `CLAUDE.md` if present — what is this project actually trying to do?

**GitHub issues** — if the GitHub MCP tool is available, fetch open issues (`gh issue list --limit 10 --state open` or equivalent). Open issues are often the most direct signal of what the project actually needs. If no MCP, check for a `.github/` directory or issue tracker hint in the README.

If the project has a test suite, check for obvious signals of broken tests (e.g. a CI badge in the README, or recent commits mentioning "fix tests") — but don't run them unless you have reason to think it'll be quick.

## Step 2: Synthesize

Group what you found into loose buckets — you don't need to present all of them, just use this to think:

- **Unfinished business** — stashes, in-progress changes, stale branches with recent commits
- **Known problems** — TODOs, FIXMEs, anything marked broken or skipped
- **Natural next steps** — based on the recent commit trajectory, what would logically come next?
- **Health & maintenance** — things that look messy, undocumented, fragile, or technically risky
- **Creative** — based on what the project is trying to do, what would make it meaningfully better?

## Step 3: Present options

Open with **one or two sentences** reading the project's current state — just enough to show you've looked around.

Then present **3–5 options**, each with:
- A short label (you can number them or give them a name)
- One sentence on *why* it's worth considering, grounded in what you actually found — two sentences only if the context genuinely needs it
- A rough sense of the scope: quick win, afternoon project, or bigger lift

Vary the type of options so the user can pick based on their energy today — not everything should be a big feature. Mix quick wins with meatier work, maintenance with new stuff. Resist the urge to over-explain; if the option name and scope label are clear, the description can be very short.

End with something like: *"Which of these sounds good, or is there something else on your mind?"*

## Tone

You're a fellow dev helping them get unstuck, not a project manager assigning work. Keep it warm, curious, and brief. The goal is to give them just enough to pick from — not an exhaustive audit.

If the project is brand new or nearly empty, lean into the creative options and help them think about what to build first.
