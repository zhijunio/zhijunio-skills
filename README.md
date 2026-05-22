# zhijunio-skills

**Agent Skills** for **Cursor** and similar AI coding assistants: one directory per skill, with **`SKILL.md`** as the entry (`name` / `description` in YAML for discovery). Some skills add **`references/`** playbooks and **`scripts/`** for reproducible runs.

## Skills

| Directory | Summary |
|-----------|---------|
| [**bookmark**](bookmark/SKILL.md) | Save links as local Markdown bookmarks (title, tags, dedup). |
| [**diary**](diary/SKILL.md) | Diary files: paths, timestamps, images, `DIARY_VAULT_ROOT`, Git flow. |
| [**health**](health/SKILL.md) | Audit the AI collaboration stack (rules, MCP, hooks, secrets); `scripts/collect-context.sh`, `references/health-methods.md`. |
| [**jinrishici**](jinrishici/SKILL.md) | Today’s poem API; fixed Chinese display format. |
| [**keep**](keep/SKILL.md) | Sync Keep runs to Garmin-style `running.json` (`keep/scripts/`). |
| [**learn**](learn/SKILL.md) | Multi-source → structured long-form / canonical reference; chains with **read**, **humanize**. |
| [**read**](read/SKILL.md) | URL / PDF → Markdown; see `read/references/` for Feishu, WeChat, proxies, MCP. |
| [**humanize**](humanize/SKILL.md) | De-AI polish, bilingual/release/social/review modes; word lists in `humanize/references/` (formerly `write`). |
| [**edit-article**](edit-article/SKILL.md) | Split by headings, DAG reorder, section rewrite; use **humanize** for de-AI after structure. |
| [**grill-me**](grill-me/SKILL.md) | One question at a time on a plan/design, with recommended answers, until the decision tree aligns. |
| [**handoff**](handoff/SKILL.md) | Compress the session to a handoff doc (temp file + path refs) for the next agent. |

## Optional chains

```text
read (fetch) → learn (research pipeline) → humanize (de-AI)
                    ↘                      ↗
                 edit-article (reorder) ──┘
                    ↘
                 health (stack / repo hygiene audit)

grill-me (stress-test plan) ──→ learn / sdd-plan (user switches to persist)
handoff (new session) ──→ points at read / learn / humanize / edit-article, etc.
```

- **learn** Phase 1: **read** scripts and `read-methods.md`.
- **learn** Phase 5: **humanize**; messy structure → **edit-article** then **humanize**.
- **health** stands alone for rules/MCP/secret hygiene.
- **grill-me** / **handoff** are outside SDD increment contracts; app repos use installed `sdd-plan`, etc.

## Usage

1. Add this repo to your host’s **Skills** config so each `SKILL.md` is indexed.
2. Skills usually trigger from **`description`** match; you can also name a skill in the prompt.
3. Scripted skills (**read**, **health**, **keep**) document commands in `SKILL.md`; install deps (`bash`, `python3`, `requests`, …) on the machine.

## Layout

```text
<skill>/
  SKILL.md           # entry: name, description, boundaries
  references/        # optional playbooks
  scripts/           # optional shell / Python
```

## Maintenance

- Root **`renovate.json`** for dependency update proposals when Renovate is enabled.

## Acknowledgements

Early **read / humanize / learn / health** layering drew on **[Waza](https://github.com/tw93/Waza)** (MIT). **handoff**, **grill-me**, and **edit-article** flows reference **[mattpocock/skills](https://github.com/mattpocock/skills)** (MIT). This repo’s `SKILL.md`, `references/`, and `scripts/` are maintained independently; **credits do not imply 1:1 parity** with upstream installs.

## License

**[MIT License](LICENSE)** for the repo. Per-file third-party notices in skill bodies or scripts apply where stated.

---

Open an Issue if you want install screenshots or CI checks for SKILL frontmatter.
