---
name: write
description: 去 AI 味、就地润色中英文正文；改稿、审稿、双语排版、发版说明、社媒短文。在用户明确要求写/改 prose、润色、去套话、release notes、推文审稿时使用。不用于代码注释、commit message、行内技术文档。执行前按 references/write-methods.md 加载分语言/分模式参考。
---

# Write：去 AI 味，改得像人写的

**词表与分模式清单** 在 `write/references/`，本页只保留边界与硬规则。

首条回复可在句首内联加 `🥷`（不要单独成段）。

## 执行前必读

1. 打开 **[`write/references/write-methods.md`](references/write-methods.md)**，按其中 **加载路由** 阅读对应 reference（中文 / 英文 / 双语 / 发版 / 社媒 / 文档审稿等）。
2. 读完再改；**不要**在未读路由表时凭印象硬套词表，避免中英文规则混用。

## 边界

- **只做自然语言**：不替代代码审查、不改写 commit message（除非用户明确说「这条 commit message 当文案润色」）。
- **意思优先于文风**：删套话不能扭曲作者原意。

## 起飞前（不满足则先问一句）

1. **有正文吗？** 用户只下指令没贴文本 → 请用户粘贴或指路径。
2. **受众锁了吗？** 无法从文本推断（博客 vs 邮件 vs RFC）→ 先问再改。
3. **语言**：以**被编辑文本**为准选 reference（见 `write-methods.md`）；用户用中文下指令不代表正文一定是中文稿。

## 硬规则

- **就地编辑**：默认不重排标题层级、不合并章节、不调换段落顺序，除非用户明确要求改结构。
- **默认零 meta**：输出 **改后的正文**；不要默认附「改动列表」或长篇解释，除非用户要 changelog 式说明。
- **不堆高级词**：目标是自然、清晰，不是「显得厉害」。

## 分模式细节（均在 references）

| 需求 | 见 |
|------|-----|
| 中文套话、语体 | [`write-zh.md`](references/write-zh.md) |
| 英文套话、语体 | [`write-en.md`](references/write-en.md) |
| 中英混排、双语对照 | [`write-bilingual.md`](references/write-bilingual.md) + 指北链接见内文 |
| Release / changelog | [`write-release-notes.md`](references/write-release-notes.md) |
| 社媒 / 推文 | [`write-social.md`](references/write-social.md) |
| 长文档审稿、隐私、段落连贯诊断 | [`write-document-review.md`](references/write-document-review.md) |

## Gotchas

| 情况 | 处理 |
|------|------|
| 把博客改成论文腔 | 按受众降维，口语可保留 |
| 用户没要数改列表却输出 diff 清单 | 默认只交正文 |
| 对纯英文稿套「中英空格」规则 | 仅中英混排时适用（见 `write-bilingual.md`） |

## 输出

默认：**仅润色后的全文**。若因截断或多解需在文末 **一句** 说明，否则无前言后语。
