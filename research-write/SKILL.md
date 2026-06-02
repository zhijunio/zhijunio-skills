---
name: research-write
description: Multi-source materials to structured long-form or canonical reference — collect, digest, outline, write, de-AI, pre-publish checks. Load references/research-methods.md before starting. For deep research, research reports, canonical articles; not for one-off search or a single link (use fetch-content).
---

# Research-write — from sources to publishable structure

Works best chained with **`fetch-content`**, **`rewrite-article`**, and **`humanize`**.

You may inline `🥷` at the start of the first reply.

**Phase playbooks, draft paths, review, and handoff** live in [`references/`](references/); this page keeps boundaries and phase summary.

## Before you start

1. Open **[`references/research-methods.md`](references/research-methods.md)** — mode, **`drafts/<slug>/`** layout, phase router.
2. Confirm **topic**, **audience**, and **mode** with the user (default Quick Reference if unsure).

## Boundaries

- **Single link, fetch only** → **`fetch-content`**.
- **Single link + summary** → **`fetch-content`** then answer; full pipeline optional.
- **`research-write`** = **multiple sources** + **new structure**.
- **Skill docs** describe workflow only — not tied to any file under `drafts/` ([`research-methods.md`](references/research-methods.md) §6).

## Prerequisites (non-blocking)

- Phase 1 fetch → **`fetch-content`** ([`collect-phase.md`](references/collect-phase.md)).
- Structure messy after Phase 4 → **`rewrite-article`** then **`humanize`** ([`handoff-chain.md`](references/handoff-chain.md)).
- Phase 5 de-AI → **`humanize`** (`write-qa-layers.md` L1–L2; 质检 → L1–L4 report).

## Modes

| Mode | Goal | Entry | Ends at |
|------|------|-------|---------|
| **Deep Research** | Understand deeply enough to write | Phase 1 | Phase 6 draft |
| **Quick Reference** | Fast mental model | Phase 2 | Phase 2 notes |
| **Write to Learn** | Existing notes; write to learn | Phase 3 | Phase 6 draft |
| **Canonical Article** | One piece replaces further searching | Phase 1 | Phase 6 + extras below |

**Canonical extras:** subtopic sections; principle + example; pitfalls; further reading 3–5 (mark beginner-friendly); ask: *Can someone act from this article alone?*

## Phases (details in references)

| Phase | Reference |
|-------|-----------|
| 1 Collect | [`collect-phase.md`](references/collect-phase.md) |
| 2 Digest | Cut ~half weak/duplicate; note factual conflicts |
| 3 Outline | [`outline-phase.md`](references/outline-phase.md) — confirm before Phase 4 on long pieces |
| 4 Fill In | Section by section; stuck → that section back to Phase 2 |
| 5 Refine | [`handoff-chain.md`](references/handoff-chain.md) |
| 6 Review | [`review-checklist.md`](references/review-checklist.md) — user publishable → stop; no auto-post |

## Draft output (this repo)

| Path | Use |
|------|-----|
| `research-write/drafts/<slug>.md` | Simple single-file draft |
| `research-write/drafts/<slug>/` | `sources/`, `source-index.md`, `outline.md`, `draft.md` |

Example: [`drafts/<slug>.md`](drafts/) or [`drafts/<slug>/draft.md`](drafts/).

## Gotchas

| Situation | Handling |
|-----------|----------|
| Second-hand articles only | Phase 1: add primary sources |
| **`fetch-content`** available but bare `curl` | Use full fetch chain |
| Phase 2 = summary only | Digest is modeling, not abbreviation |
| User OK to publish | Do not post unless explicitly asked |

## References

| File | Contents |
|------|----------|
| [`research-methods.md`](references/research-methods.md) | Router, modes, draft layout |
| [`collect-phase.md`](references/collect-phase.md) | Discover → Fetch → File |
| [`outline-phase.md`](references/outline-phase.md) | Outline template, version rows |
| [`handoff-chain.md`](references/handoff-chain.md) | rewrite-article / humanize |
| [`review-checklist.md`](references/review-checklist.md) | Phase 6 review |
