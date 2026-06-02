# Phase 1 — Collect (Discover → Fetch → File)

## 1. Discover (no full fetch yet)

1. Confirm **topic**, **audience**, and **mode** (see `research-methods.md`).
2. List **5–10 URLs** for a blog-level piece; **15–20** for deep survey (trim by scope).
3. Prefer **primary sources**:

| Good | Avoid as only basis |
|------|---------------------|
| Official docs, JEPs, specs | SEO aggregator rewrites |
| Maintainer / engineering blogs | Unsourced tutorial chains |
| Papers, authoritative repos | Single Medium post |

4. For **technical JVM/OS/runtime** topics, see **`fetch-content/references/research-sources.md`**.

## 2. Fetch (each URL)

Use **`fetch-content`**:

```bash
bash fetch-content/scripts/fetch-url.sh "https://…"
```

- On success: save body under `drafts/<slug>/sources/<short-name>.md`.
- On failure: try **`fetch-content/references/mcp-first.md`**; report honestly — **never invent** source text.
- Record in **`source-index.md`**:

```markdown
| # | URL | Method | File | Notes |
|---|-----|--------|------|-------|
| 1 | https://www.rfc-editor.org/rfc/rfc9110.html | fetch-url.sh | rfc-9110.md | HTTP semantics |
```

**Method** = `fetch-url.sh`, `firecrawl`, `mcp`, etc.

## 3. File (organize)

**Simple article** (few sources, one file):

```text
research-write/drafts/<slug>.md          # final draft lives here
research-write/drafts/<slug>/sources/  # optional snapshots
```

**Multi-source project**:

```text
research-write/drafts/<slug>/
  source-index.md
  sources/
  outline.md      # Phase 3
  draft.md        # Phase 4+
```

If `save-md.sh` wrote to `~/Downloads/`, **move** into `sources/` and update the index — avoid re-fetch.

## 4. Scale and stop rules

- Enough when every **planned outline section** has at least one primary source tagged.
- Too many second-hand explainers → add primaries, do not proceed to Phase 4.

## 5. Anti-patterns

| Do not | Do instead |
|--------|------------|
| Skip fetch-content for `curl` on CN/paywall/JS pages | Full fetch chain |
| Paste search snippets as “sources” | Fetch or cite with URL |
| One 5000-word secondary post as sole research | JEP / spec / source code |
