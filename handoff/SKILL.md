---
name: handoff
description: 把当前对话压缩成交接文档，供新 Agent 续作；含建议技能、路径引用、脱敏。用户说 handoff、交接、换会话续写，或长任务结束要交接时使用。不写 plan、不替代 docs/sdd 增量契约。
argument-hint: "下一程主要做什么？"
---

# Handoff — 会话交接

为**下一个 Agent / 新会话**写一份交接文档，便于续作。灵感来自 [mattpocock/skills `handoff`](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff)（MIT），本仓增加落盘路径与中文约定。

## 边界

- **不是** `sdd-plan` / 业务仓 `docs/sdd/plans/` 增量契约。
- **不重复** 已有制品全文 —— PRD、plan、ADR、issue、commit、diff 等 **用路径或 URL 引用**。
- **脱敏**：API key、密码、token、PII 等一律打码或概括。

## 落盘

1. 用 `mktemp -t handoff-XXXXXX.md` 生成路径（先读命令输出路径）。
2. 将交接文档写入该文件。
3. 在对话里告知用户**绝对路径**，便于粘贴到新会话。

## 文档结构（建议）

```markdown
# Handoff — <主题>

## 下一程目标
<用户 argument-hint 或对话约定>

## 当前状态
- 已完成：…
- 进行中：…
- 阻塞：…

## 关键路径与引用
- 仓库 / 分支 / PR：…
- 计划或设计稿：…
- 相关提交：…

## 决策与约定
- 已拍板：…
- 待决：…

## Suggested skills
- <skill-name> — 为何下一程应 Read 它

## 不要重复做的事
- …
```

## 与 zhijunio-skills 链式

| 下一程可能 | 建议 Read |
|------------|-----------|
| 继续抓取材料 | `read` |
| 多源研究写作 | `learn` |
| 去 AI 味润色 | `humanize` |
| 重组长文章节 | `edit-article` |
| 压测方案 | `grill-me` |
| 代码增量 SDD | 用户安装的 `sdd-plan` / `sdd-build` 等（本仓外） |

## 若用户传了 argument-hint

把其视为**下一程焦点**，收紧「下一程目标」与 **Suggested skills**，省略无关历史。
