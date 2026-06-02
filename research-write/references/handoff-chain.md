# Handoff chain — rewrite-article & humanize

Default pipeline after research-write drafting:

```text
fetch-content → research-write → rewrite-article? → humanize
```

## 1. When to invoke rewrite-article

| Signal | Action |
|--------|--------|
| Section order wrong (conclusion before setup) | **`rewrite-article`** — confirm outline first |
| User: 重排 / reorder / 结构乱 | **`rewrite-article`** |
| Only wording / de-AI | **`humanize`** only |
| Phase 4 draft is long and logic jumps | **`rewrite-article`** then **humanize** |

**Order:** structure settled → **`humanize`**. Do not de-AI inside rewrite-article body pass.

## 2. When to invoke humanize

| Signal | Action |
|--------|--------|
| Phase 5 refine / de-AI / 润色 / 去 AI 味 | **`Read` `humanize`** + `write-methods.md`; run **L1–L2** in place (`write-qa-layers.md`) |
| 质检 / QA report / 检查报告 | **`humanize`** + `write-qa-layers.md` L1–L4 + report template |
| Chinese technical long-form | **`write-qa-layers.md`** L1–L4 + `write-zh.md` |
| English-only draft | `write-en.md` |

Pass **latest full draft** (path under `drafts/<slug>.md` or `draft.md`).

## 3. Phase 5 refine (inside research-write)

Before chaining skills:

1. Cut fluff; fix broken flow and missing citations.
2. **Do not** add wholly new sections the user did not ask for.
3. If structure still wrong → **rewrite-article**, not more Phase 5.

## 4. Phase 6 review

Run [`review-checklist.md`](review-checklist.md). User says publishable → **stop** — no blog post, social, or PR unless explicitly asked.

## 5. Example chain (generic)

Topic: `<slug>` (any multi-source explainer).

1. Phase 1: primary sources via **fetch-content** → `drafts/<slug>/sources/`
2. Phase 4: `drafts/<slug>.md` or `drafts/<slug>/draft.md`
3. User asks reorder → **rewrite-article** (confirm outline first)
4. User asks polish → **humanize** + mode refs from `write-methods.md` + `write-qa-layers.md` L1–L2
5. Phase 6: `review-checklist.md` + L3 technical gate when applicable
