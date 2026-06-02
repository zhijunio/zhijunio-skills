# Research-write reference router (this repo)

Read this file before a multi-source writing task. Load references for the current phase.

## 1. Loading router

| Phase / need | Required reference |
|--------------|-------------------|
| Mode choice, boundaries, draft paths | This file §2–§3 |
| Phase 1 Discover → Fetch → File | [`collect-phase.md`](collect-phase.md) |
| Phase 3 outline, version rows (tech) | [`outline-phase.md`](outline-phase.md) |
| Phase 5–6 → rewrite-article / humanize | [`handoff-chain.md`](handoff-chain.md) |
| Pre-publish review (Phase 6) | [`review-checklist.md`](review-checklist.md) |

**Fetch URLs** → **`fetch-content`** (`fetch-methods.md`, `fetch-url.sh`). **Do not** bare `curl` when `fetch-content` exists.

## 2. Modes (confirm with user)

| Mode | Goal | Start | Stop |
|------|------|-------|------|
| **Deep Research** | Understand enough to write | Phase 1 | Phase 6 draft |
| **Quick Reference** | Fast mental model | Phase 2 | Phase 2 notes |
| **Write to Learn** | Write from existing notes | Phase 3 | Phase 6 draft |
| **Canonical Article** | One piece replaces re-searching | Phase 1 | Phase 6 + canonical extras in parent `SKILL.md` |

Default if unsure: **Quick Reference** — confirm once.

## 3. Draft layout (this repo)

`RESEARCH_ROOT` = `research-write/` in this repo.

| Path | Contents |
|------|----------|
| `drafts/<slug>.md` | Single-file draft (simple articles) |
| `drafts/<slug>/draft.md` | Main article (multi-source projects) |
| `drafts/<slug>/sources/` | One file per fetched URL |
| `drafts/<slug>/source-index.md` | URL, fetch method, filename, notes |
| `drafts/<slug>/outline.md` | Phase 3 outline (optional) |

**Slug:** lowercase, hyphenated (e.g. `http-cache-semantics`, `grpc-flow-control`).

## 6. Skills vs `drafts/` (no golden samples)

- **`references/` and parent `SKILL.md`** use **`<slug>` placeholders only**.
- **Do not** cite a specific file under `research-write/drafts/` as a canonical example, golden sample, or skill test fixture.
- Files in `drafts/` are **session output** for the user; skill behavior must not depend on any one draft existing in the repo.

## 4. Phase map (short)

| Phase | Do |
|-------|-----|
| 1 Collect | Primary sources; fetch via **fetch-content**; file under `drafts/<slug>/` |
| 2 Digest | Cut ~half weak material; note conflicts |
| 3 Outline | Section ↔ primary source; **confirm outline** before Phase 4 on long/canonical pieces |
| 4 Fill In | Write section by section |
| 5 Refine | Cut fluff; chain **rewrite-article** if structure messy; then **humanize** |
| 6 Review | [`review-checklist.md`](review-checklist.md); user says publishable → stop (no auto-post) |

## 5. Sibling skills

| Skill | When |
|-------|------|
| **`fetch-content`** | Each URL/PDF in Phase 1 |
| **`rewrite-article`** | Section order wrong after Phase 4, or user asks reorder |
| **`humanize`** | Phase 5 de-AI / register; technical long-form → `write-qa-layers.md` L1–L4 |
| **`grill-me`** | Stress-test a plan before research — does not write files |
