---
name: read
description: Turn URLs or PDFs into clean Markdown for citation, archive, or downstream learn/humanize. Use when the user gives a link, wants a page read, article fetch, or PDF text. Prefer scripts in this skill directory; not for plain text files already in the repo (use the Read tool).
---

# Read — URL / PDF → Markdown

This skill is self-contained under **`read/scripts/`** + **`read/references/read-methods.md`**; paths and commands are relative to this repo.

You may inline `🥷` at the start of the first reply.

## Before running

Open and follow:

**[`read/references/read-methods.md`](references/read-methods.md)**

Covers: proxy chain order, `read-url.sh` / `pdf-extract.sh` / `save-md.sh`, paywalls, WeChat / Feishu / X, MCP pairing.

## Path convention

- Workspace at repo root: `READ_ROOT` = `read` (relative) or absolute `.../zhijunio-skills/read`.
- Example:

```bash
bash read/scripts/read-url.sh "https://…"
```

## Boundaries

- **Default: convert only** — no summary or interpretation unless the user asks **after** fetch.
- **Non-PDF text already in the repo**: use the editor Read tool, not this skill.

## Routing summary (details in read-methods)

| Scenario | Approach |
|----------|----------|
| Generic URL | `read-url.sh` (defuddle → jina → curl) |
| WeChat articles | `read-url.sh` (**jina → defuddle** to reduce false paywall kills) |
| Feishu / Lark | **`fetch_feishu.py`** when `FEISHU_APP_*` set; else jina/defuddle fallback (often fails) |
| GitHub blob | raw in script + optional `gh` |
| Local/remote PDF | `pdf-extract.sh` or PDF branch in `read-url.sh` |
| Heavy anti-bot / JS | Configured **Firecrawl etc. MCP** before scripts |

## Suggested output shape

```text
Title:  {title}
Author: {author if known}
Source: {site or type}
URL:    {original link}

Content
{Markdown body; truncate with a note if too long}
```

## Saving

- **Default**: show Markdown in chat only; **no new file**.
- User says **save / download**, or **`learn`** Phase 1 needs files: pipe `read-url.sh` to `save-md.sh` (read-methods §3).
- No need to stress “I didn’t write a file” when not saving.

## Images

Do not bulk-download by default. If the user asks for images, extract URLs from Markdown, download to a folder, report success/failure per URL.

## Gotchas

| Situation | Handling |
|-----------|----------|
| “Read this” but they want a summary | Deliver Markdown first; then offer summary |
| Response is JSON | Extract body field before display |
| Content too long | Truncate with note, or `head -n 200` preview |

## Pairing with `learn`

Use this skill per URL in multi-source research; naming on disk should match `learn` Phase 1 conventions.
