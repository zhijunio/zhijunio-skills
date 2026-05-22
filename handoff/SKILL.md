---
name: handoff
description: Compress the current conversation into a handoff document for the next agent; includes suggested skills, path references, and redaction. Use when the user says handoff, session handover, continue in a new chat, or a long task needs a clean transfer. Does not write plans or replace docs/sdd increment contracts.
argument-hint: "What should the next session focus on?"
---

# Handoff — session transfer

Write a handoff document for the **next agent / new session** so work can continue. Inspired by [mattpocock/skills `handoff`](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) (MIT), with temp-file output in this repo.

## Boundaries

- **Not** `sdd-plan` or app-repo `docs/sdd/plans/` increment contracts.
- **Do not duplicate** full text of existing artifacts — reference PRDs, plans, ADRs, issues, commits, diffs by **path or URL**.
- **Redact** API keys, passwords, tokens, PII (mask or summarize).

## Write to disk

1. Run `mktemp -t handoff-XXXXXX.md` and read the returned path.
2. Write the handoff document to that file.
3. Tell the user the **absolute path** so they can paste it into a new session.

## Suggested document shape

```markdown
# Handoff — <topic>

## Next-session goal
<argument-hint or agreed focus>

## Current state
- Done: …
- In progress: …
- Blocked: …

## Key paths and references
- Repo / branch / PR: …
- Plans or design docs: …
- Relevant commits: …

## Decisions and conventions
- Settled: …
- Open: …

## Suggested skills
- <skill-name> — why the next session should Read it

## Do not repeat
- …
```

## zhijunio-skills chain hints

| Next session likely needs | Suggest Read |
|---------------------------|--------------|
| More fetching | `read` |
| Multi-source research writing | `learn` |
| De-AI polish | `humanize` |
| Reorder long-article sections | `edit-article` |
| Stress-test a plan | `grill-me` |
| Code increment SDD | User-installed `sdd-plan` / `sdd-build` (outside this repo) |

## If argument-hint is provided

Treat it as the **next-session focus**; tighten **Next-session goal** and **Suggested skills**; omit irrelevant history.
