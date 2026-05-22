# Humanize reference router (this repo)

Read this file before editing. Load references from the **text being edited** (not the user’s instruction language).

## 1. Loading router

| Text and task | Required reference |
|---------------|-------------------|
| Primarily Chinese body copy | [`write-zh.md`](write-zh.md) |
| Primarily English body copy | [`write-en.md`](write-en.md) |
| Mixed ZH/EN, bilingual pairs, translation review | [`write-bilingual.md`](write-bilingual.md); add `write-zh.md` / `write-en.md` as needed |
| Release / changelog | [`write-release-notes.md`](write-release-notes.md) |
| Twitter / X / short social | [`write-social.md`](write-social.md) |
| Whitepaper / long-doc review (incl. privacy scan) | [`write-document-review.md`](write-document-review.md) |
| Coherence scan only, no full rewrite | [`write-document-review.md`](write-document-review.md) — “paragraph coherence” section |

If the user asks for multiple modes (e.g. bilingual release notes), **merge rules top-down**; on conflict, prefer **unchanged meaning, in-place edit, minimal meta** (see parent `SKILL.md`).

## 2. Relationship to parent `SKILL.md`

- **Hard rules, boundaries, output contract** → **`humanize/SKILL.md`** in this repo.
- This directory adds **checklists, word lists, mode notes** so `SKILL.md` stays short.

## 3. External links (not vendored)

- Chinese copy style: [中文文案排版指北](https://github.com/mzlogin/chinese-copywriting-guidelines)
