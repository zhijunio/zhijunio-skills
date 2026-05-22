---
name: edit-article
description: Split by headings, reorder by information dependency (DAG), then rewrite long articles section by section; keep paragraphs under ~240 characters when possible. Use to fix structure, reorder chapters, improve logic and readability. For de-AI polish without reordering, use humanize.
---

# Edit article — structure and section rewrite

Completes [mattpocock/skills `edit-article`](https://github.com/mattpocock/skills/tree/main/skills/personal/edit-article) (MIT). Split from **`humanize`**: this skill handles **structure and in-section rewrite**; **humanize** defaults to in-place polish without reordering sections.

## Boundaries

- **Targets**: blogs, newsletters, long technical **Markdown/articles** — not code, not commit messages.
- **Does not replace humanize**: after structure is settled, point the user to **`Read` `humanize`** for de-AI polish.
- **Does not replace learn**: research-from-scratch long-form → **`learn`**.

## Flow

### 1. Sections and dependencies

1. Split by **headings**; clarify what each section must convey.
2. Treat information as a **DAG**: prerequisites before dependents.
3. Propose a **section order** (merge/split allowed); **confirm with the user** before editing body text.

### 2. Section-by-section rewrite

For each section (in confirmed order):

1. **Rewrite** for clarity, flow, and pace; **aim for ≤ 240 characters per paragraph** (CJK by character, Latin by character count; slight flexibility OK, keep paragraphs short).
2. Preserve the author’s facts and stance; do not add unverified claims.
3. Finish one section before the next (report progress per section on very long pieces).

### 3. Wrap-up

1. Read end-to-end: transitions, duplication, gaps between sections.
2. Deliver the **full revised text** (default: update the user’s path in place, or only changed regions if asked).
3. If the user wants de-AI polish: suggest **`humanize`**; do not apply humanize word lists inside this skill.

## Before you start

- Need article path or full text; otherwise ask the user.
- Confirm whether **heading levels**, deletions, and merges are allowed (default: propose in the confirmation step).

## Output

Default: **revised full text only** (same as humanize — minimal meta). Add a short change summary only if the user asks.
