# Chinese body copy: de-AI polish

## Quick pass (before editing)

1. **Cut filler only**: remove evaluative adverbs and boilerplate clauses; if facts break, keep facts and drop tone only.
2. **Do not compress paragraphs** (see next section): one vague sentence → rewrite that sentence; do **not** merge three explanations into one telegraphic line.
3. **Plain SVO**: avoid empty frames like 「在…的背景下」「以…为抓手」; replace with a concrete subject.
4. **No faux depth**: 「本质上」「底层逻辑」「范式」— use concrete verbs or delete unless academic prose needs them.
5. **Punctuation and register**: colloquial 「吧、呢」 OK in casual posts; formal docs stay steady without hollow parallelisms.

## Do not compress paragraphs（必守）

**去 AI 味 ≠ 压段落。** 常见误操作：删掉套话后，把原来两段机制说明压成两句提纲，读起来像笔记。

| Do | Don't |
|----|--------|
| 删掉「综上所述」「值得注意的是」等套话 | 为「简洁」把一整段压成一行 |
| 把空洞句改写成具体主语 + 动词 | 合并多个因果步骤成一句省略主语的短句 |
| 原文偏长但信息都在 → 保留信息量，只改措辞 | 人为缩短 § 字数作为默认目标 |
| 改完后 § 仍读得顺、因果完整 | 改完后像 bullet 提纲、读者要自己补脑 |

**Heuristic:** 技术长文每个 `###` 下，通常至少 **2–4 句完整说明**（列表、代码、表除外）。若 humanize 后只剩 1 句且该节原先讲机制，**补回**衔接与因果（用原文已有信息）。

**Short punch sentences** are OK as *one* sentence in a paragraph — not as the *only* sentence for a whole subsection.

## High-frequency AI tells (delete or rewrite)

- Openers: 综上所述、值得注意的是、不难发现、让我们、不妨、在此前提下
- Transitions: 与此同时、基于此、在这一过程中、从某种程度上说、不可否认的是
- Closers: 总而言之、一言以蔽之、以期、以期实现、具有十分重要的意义
- Business-speak: 深度赋能、一站式、显著提升、全面助力、打造闭环、矩阵式、颗粒度、对齐、拉通、落地
- Praise-speak: 极具、颇为、相当程度、一定程度上、令人瞩目、可圈可点

## Replacement table (L1 scan — prefer these over bans)

Search banned phrasing; replace in place. Keep meaning; do not add new facts.

| Avoid (AI tell) | Prefer |
|-----------------|--------|
| 说白了 | 其实就是、直接讲 |
| 这意味着 / 意味着什么？ | 所以、结果是 |
| 本质上 | 说到底、其实（或删掉） |
| 换句话说 | 也就是说、你想想看 |
| 不可否认 | 删掉，正面陈述 |
| 综上所述 / 总的来说 | 具体回扣一句结论，或删掉 |
| 首先…其次…最后… | 口语转场：说到这个、另一头、还有 |
| 值得注意的是 / 不难发现 | 删掉，直接写事实 |
| 让我们来看看 / 接下来让我们 | 删掉，直接进内容 |
| 在当今…的时代 / 随着…的发展 | 删掉；从具体事件或问题切入 |
| 深度赋能 / 显著提升 / 打造闭环 | 具体动词 + 可验证结果（仅当原文已有数据） |

More L1 checks and optional QA report: [`write-qa-layers.md`](write-qa-layers.md).

## Encouraged patterns (casual Chinese — optional)

Not required every paragraph; use when the draft still sounds like a template.

- **Concrete opener:** problem or scene first, not 「在当今…的时代」
- **Short bridge after tangents:** 说到这个、回到正题、另一头
- **Plain judgment:** 我觉得、其实、直接讲 — OK for blog; avoid in RFC unless author already uses them
- **Admit limits:** 以你环境为准、我还没在生产验证 — when the draft already implies uncertainty

Persona-only writing skills（固定作者、禁用标点、禁止小标题）**不要**套在技术长文上；见 [`write-qa-layers.md`](write-qa-layers.md) persona boundary.

## Mechanical patterns

- **Triple parallel** «不仅…而且…更…» with no concrete info → split or drop the emptiest layer.
- **「既 A 又 B，既 C 又 D」** with no real contrast → one conditional or result sentence.
- **Every paragraph starts with 「在…中」** → vary at least half the openings; use concrete subjects.

## Register by audience

| Audience | Guidance |
|----------|----------|
| Blog / personal | Colloquial OK; avoid 「笔者」「本文旨在」 |
| Email / IM | Short, direct questions; less 「烦请查阅如下信息」 |
| External RFC / design | Precise definitions + lists OK; still cut empty phrases |

## Self-check (one question after edit)

「Would a senior practitioner still write it this way?» If not, trim tone or add detail **only from what the user already provided** — do not invent facts.

**Technical long-form (Chinese):** also run [`write-qa-layers.md`](write-qa-layers.md) L1–L4 add-ons.
