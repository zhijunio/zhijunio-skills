# Phase 6 — review checklist (technical long-form)

Run before calling a draft publishable. User must still read twice; this list is for agent + author.

## 1. Verdict

| Verdict | Meaning |
|---------|---------|
| **APPROVE** | Ready for user’s final read and external publish |
| **REQUEST CHANGES** | Fix listed items first |

## 2. Structure & numbering

- [ ] Heading levels consistent (`##` / `###`); **no duplicate section numbers**
- [ ] TL;DR or intro matches body (if present)
- [ ] Mermaid / tables render on target platform (or export static image)

## 3. Technical accuracy

- [ ] Claims trace to **primary sources** cited or in `source-index.md`
- [ ] **Version boundaries** clear (e.g. old release vs current LTS — state both, do not merge)
- [ ] No **git jargon** where **JDK version** is what readers need (`master` → `JDK 17+` / tagged source)
- [ ] No invented quotes, stats, or API behavior

## 4. Code & examples

- [ ] Examples safe to copy (no infinite loops without comment)
- [ ] “示意 / 勿在生产抄” where appropriate
- [ ] No stray English in Chinese prose (`alone` → 中文)

## 5. Style (humanize)

- [ ] L1–L2 passed: `humanize/references/write-qa-layers.md` (bans + audience + technical add-on when applicable)
- [ ] AI tells trimmed: `humanize/references/write-zh.md` or `write-en.md` replacement tables
- [ ] Paragraphs not over-compressed after de-AI (`write-zh.md` § Do not compress; L2-2b in `write-qa-layers.md`)
- [ ] Register matches audience (blog vs RFC)
- [ ] User asked 质检 / QA report → L4 note in `write-qa-layers.md` report template (optional)

## 6. Links & metadata

- [ ] Links full URL; JEP / spec / GitHub paths valid
- [ ] Further reading: 3–5 items for canonical mode; mark beginner-friendly

## 7. Publish boundary

- [ ] **Do not** post to blog, social, or open PR unless user explicitly asks
- [ ] Privacy: no internal codenames, credentials, unreleased products

## 8. Report shape (when user asks for review notes)

```markdown
**Verdict:** APPROVE | REQUEST CHANGES

| Level | Item | Fix |
|-------|------|-----|
| 🔴 / 🟠 / 🟡 | … | … |
```

Findings only — full revised body is a separate **humanize** or edit pass unless user asks.
