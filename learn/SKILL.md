---
name: learn
description: Multi-source materials to structured long-form or canonical reference — collect, digest, outline, write, de-AI, pre-publish checks. For deep study, research reports, canonical articles; not for one-off search or a single link (use read).
---

# Learn — from sources to publishable structure

Works best chained with **`read`** (fetch), **`humanize`** (de-AI), and **`edit-article`** (long-form reorder).

You may inline `🥷` at the start of the first reply.

## Boundaries

- **Single link, fetch only** → use **`read`**.
- **Single link + summary/opinion** → `read` then answer; full pipeline optional.
- **`learn`** = **multiple sources** + **new structure** (article / reference note / one canonical piece).

## Prerequisites (non-blocking)

If this repo also has **`read` / `humanize`**: Phase 1 fetch via `read`; Phase 5 polish/de-AI via `humanize`; reorder sections with `edit-article` first when needed. If missing: use the host’s fetch; de-AI manually against `humanize` checklists.

## Choose a mode (confirm with user; default Quick Reference if unsure)

| Mode | Goal | Entry | Ends at |
|------|------|-------|---------|
| **Deep Research** | Understand deeply enough to write | Phase 1 | Phase 6 publishable draft |
| **Quick Reference** | Fast mental model | Phase 2 | Phase 2 notes enough |
| **Write to Learn** | Existing notes; write to learn | Phase 3 | Phase 6 publishable draft |
| **Canonical Article** | One piece replaces further searching | Phase 1 | Phase 6 single authoritative article |

### Canonical extras

- Major subtopics get their own sections; no critical content buried in a one-line aside.
- **Examples**: principle + actionable example.
- **Common pitfalls** and how to avoid them.
- **Further reading** 3–5 items; mark **best for beginners** (1–2).
- Phase 6 ask: **Can someone understand or act from this article alone?**

## Phase 1: Collect

- Prefer **primary sources**: papers, official docs/blogs, maintainer design notes, authoritative repos. **Avoid second-hand explainers as the only basis**.
- Per source: **Discover** (URL list, no full fetch yet) → **Fetch** (each URL via **`read`**) → **File** (save under a research subfolder; **move** downloads to avoid re-fetch).
- Scale: blog-level **5–10** sources; deep survey **15–20** (trim by topic).

## Phase 2: Digest

- Read through; **cut roughly half** weak or duplicate material.
- For outline claims: repeated across sections? transferable? field consensus? **Do not force narrow “golden quotes.”**
- **Factual conflict**: present both sides with sources; do not pick a winner by default.

## Phase 3: Outline

- Each section tags **primary sources**; unsourced sections → delete or return to Phase 1.
- Unstable outline → **do not enter Phase 4**.

## Phase 4: Fill In

- Write section by section; stuck on one section → that section back to Phase 2, not a full restart.
- **Stuck signals** (any): opening rewritten 3+ times; section rests on one uncross-checkable source; needs sources not collected in Phase 1; cannot explain the claim aloud.

## Phase 5: Refine

- Brief pass: **cut fluff, flag broken argument flow, undefined terms, missing citations**; **do not write wholly new sections for the user**.
- De-AI: run **`humanize`** if available; else manual check against `humanize` quick lists.

## Phase 6: Self-review and publish boundary

- **Human** linear read at least two passes (the user, not the model as substitute).
- After the user says publishable → **stop**: **do not** post to blog, social, or open PR unless the user **explicitly** asks.

## Gotchas

| Situation | Handling |
|-----------|----------|
| Dozens of second-hand articles as “research” | Return to Phase 1; add primary sources |
| `read` available but raw `curl` everywhere | Loses paywalls, CN platforms, heavy JS pages |
| Phase 2 summary only, no model | Digest is **modeling**, not abbreviation |
| User said OK to publish but agent offers to post | Forbidden; publishing is a user action |

## Pairing with `read` in this repo

Phase 1: each URL via **`read/scripts/read-url.sh`** and **`read/references/read-methods.md`**; add **MCP (e.g. Firecrawl)** when needed. Do not replace the full fetch chain with bare `curl`.
