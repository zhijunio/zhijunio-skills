# Phase 3 — Outline

Do **not** enter Phase 4 until the outline is stable and sourced.

## 1. Outline template

```markdown
# Outline: <title>

**Audience:**
**Mode:** Deep Research | Canonical | …
**Primary thesis:** one sentence

## Sections

| # | Section | Must convey | Primary sources |
|---|---------|-------------|-----------------|
| 1 | … | … | RFC 9110 §6, vendor doc |
| 2 | … | … | spec §3.2 |

## Gaps / need more Phase 1
- …
```

## 2. Rules

- Every section row has **≥1 primary source**; empty → delete section or return to Phase 1.
- **Unstable outline** (order still debated) → stay in Phase 3.
- **Long or canonical** pieces: show outline to user and get **explicit OK** before Phase 4.

## 3. Technical articles — version row

When the topic spans **classic teaching vs current runtime** (e.g. deprecated APIs, old interview lore vs production defaults):

Add a dedicated section or table row:

| JDK / era | What reader should know |
|-----------|-------------------------|
| Older releases | Classic model (interview / docs) |
| N+ | What changed (release notes, flags) |
| Current LTS | What production cares about |

**Wording:** use **JDK versions**, not git branch names (`master`). Point readers to **tagged source** for their JDK.

## 4. DAG sanity (optional)

If section B uses terms only defined in section D → reorder or add bridge. For full DAG workflow → **`rewrite-article/references/dag-reorder.md`** or **`tech-article-dag.md`**.
