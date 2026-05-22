---
name: grill-me
description: 对已有计划或设计逐条拷问（一次一问、带推荐答案），直到决策树各分支达成共识；能查代码库则先查。用户说 grill me、拷问方案、压测设计、stress-test plan 时使用。不写文件、不替代 sdd-plan 或 learn 全文产出。
argument-hint: "要拷问的主题或文档路径（可选）"
---

# Grill me — 方案拷问

灵感来自 [mattpocock/skills `grill-me`](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me)（MIT）。

## 做什么

对用户提供的**计划、设计、架构想法**进行拷问，直到双方对**决策树各分支**理解一致。

## 硬规则

- **一次只问一个问题**；等用户回答后再问下一个。
- **每个问题附带你的推荐答案**（及简短理由），便于用户拍板。
- **能靠代码库/文档回答的，先探索**，不要问用户已知信息。
- **本技能阶段不写文件** —— 不写 `docs/sdd/plans/`、不写 brainstorm 设计稿、不 commit。
- 拷问结束后，若用户要落盘：建议 **`Read` `learn`**（长文）、**`sdd-brainstorm`** / **`sdd-plan`**（在业务仓 SDD 流程中），由用户显式切换。

## 流程

1. 确认拷问对象（用户粘贴、路径，或当前对话里的方案摘要）。
2. 列出主要决策分支（可在心里或简短列出，不必长文）。
3. 按依赖顺序逐分支追问：先决问题 → 下游问题。
4. 未决项归零或明确标记「待用户会后决定」后结束。

## 与仓库其他技能

| 技能 | 关系 |
|------|------|
| **learn** | learn 从材料**写出**结构；grill-me 对**已有**方案压测 |
| **humanize** | 无关（改 prose） |
| **edit-article** | 无关（改文章结构） |
| **handoff** | 长拷问后可 handoff 给新 Agent 继续写 plan |

## 若用户传了 argument-hint

将其视为拷问范围（例如「只问数据库迁移」），不要扩散到无关子系统。
