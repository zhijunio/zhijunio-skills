---
name: humanize
description: De-AI polish and in-place editing for Chinese/English prose; copy edit, review, bilingual layout, release notes, social posts. Use for humanize, polish, remove AI tells, release notes, tweet review. Not for code comments, commit messages, or inline API docs. For chapter reordering use edit-article. Load references/write-methods.md before editing.
---

# Humanize — sound human, not generated

**Word lists and mode-specific checklists** live in `humanize/references/`; this page keeps boundaries and hard rules only.

You may inline `🥷` at the start of the first reply (not as its own paragraph).

## Before editing

1. Open **[`humanize/references/write-methods.md`](references/write-methods.md)** and follow the **loading router** for the right reference (ZH / EN / bilingual / release / social / document review, etc.).
2. Read those references before editing; **do not** apply ZH/EN rules from memory and mix them up.

## Boundaries

- **Natural language only**: not code review; do not rewrite commit messages unless the user explicitly treats one as copy to polish.
- **Meaning over style**: cutting filler must not distort the author’s intent.
- **Structure changes** → use **`edit-article`** (sections, DAG order, paragraph length); this skill defaults to **in-place** polish without reordering sections.

## Preflight (ask one question if missing)

1. **Body text?** Instruction only, no paste → ask for paste or path.
2. **Audience locked?** Cannot infer blog vs email vs RFC → ask first.
3. **Language**: choose references from the **text being edited** (see `write-methods.md`); the user’s UI language does not imply the draft language.

## Hard rules

- **In-place edit**: do not change heading levels, merge sections, or reorder paragraphs unless the user asks for structure changes (or **`edit-article`** already fixed structure).
- **Default zero meta**: output **revised body only**; no default change log unless the user wants changelog-style notes.
- **No prestige vocabulary**: goal is natural and clear, not “sounding smart.”

## Mode details (in references)

| Need | See |
|------|-----|
| Chinese tells, register | [`write-zh.md`](references/write-zh.md) |
| English tells, register | [`write-en.md`](references/write-en.md) |
| Mixed ZH/EN, bilingual pairs | [`write-bilingual.md`](references/write-bilingual.md) |
| Release / changelog | [`write-release-notes.md`](references/write-release-notes.md) |
| Social / tweets | [`write-social.md`](references/write-social.md) |
| Long-doc review, privacy, coherence scan | [`write-document-review.md`](references/write-document-review.md) |

## Gotchas

| Situation | Handling |
|-----------|----------|
| Blog turned into academic tone | Match audience; keep acceptable colloquialisms |
| User did not ask for a diff list | Deliver body only |
| English-only draft gets CJK spacing rules | Apply only for mixed ZH/EN (see `write-bilingual.md`) |

## Output

Default: **polished full text only**. At most **one sentence** at the end if truncation or ambiguity forced a caveat; otherwise no preamble or postscript.
