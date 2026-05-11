---
name: health
description: 审计「AI 协作栈」（规则、MCP/工具、hooks、密钥与仓库卫生）。支持多 Agent 平台：先根据仓库标记文件与用户声明识别宿主，再查对应路径。涵盖 Cursor、Claude Code、Codex CLI、GitHub Copilot、Continue、Windsurf、Cline/Roo、Amazon Q、Aider 等常见落点（详见 references/health-methods.md）。默认摘要审计；可跑 health/scripts/collect-context.sh。不用于业务代码 bug 或 PR 代码审阅。
---

# Health：协作栈健康度（多 Agent 平台）

> 思路借鉴 [tw93/Waza `skills/health`](https://github.com/tw93/Waza/tree/main/skills/health)（MIT）。**多平台路径矩阵、识别步骤、检查命令** 见 **[`references/health-methods.md`](references/health-methods.md)**；**`scripts/collect-context.sh`** 会打印各平台常见标记文件是否存在，便于交叉判断。

首条回复可在句首内联加 `🥷`。

## 执行前必读

1. 打开 **[`health/references/health-methods.md`](references/health-methods.md)**：先 **§2 识别宿主**，再按 **§5 起** 勾选对应平台章节。
2. 在目标仓库根执行 **`bash health/scripts/collect-context.sh "$(git rev-parse --show-toplevel)"`**，把输出中的 **`## agent_markers`** 与 **`## paths_present`** 贴进报告 **Facts**；**勿**对敏感路径执行 `cat`。

## 多平台原则

- **同一六层模型**（项目说明 → 规则 → 技能/playbook → hooks/自动化 → 工具与 MCP → 密钥卫生）适用于所有宿主；**只有落盘路径不同**。
- **可并存**：仓库里可同时存在 `.cursor/`、`CLAUDE.md`、`.windsurfrules` 等 —— 审计时列出 **哪些生效**（问用户当前常用 Agent），标出 **重复或矛盾** 为 `[~]`。
- **未知宿主**：只做仓库通用项 + `agent_markers` 罗列；专属层标 `n/a`，不扣分。

**Claude Code 深检** 可叠加上游：[tw93/Waza — skills/health](https://github.com/tw93/Waza/tree/main/skills/health)（互补，非必需）。

### 六层 × 宿主（速查 → 细节见 health-methods）

| 层 | 说明 |
|----|------|
| 项目入口 | `README.md`、`AGENTS.md`、`CLAUDE.md`（因团队习惯而异） |
| 行为规则 | `.cursor/rules/`、`.claude/rules/`、`.windsurfrules`、`.clinerules`、`.github/copilot-instructions.md`、`.amazonq/rules/` 等 |
| 技能 / playbook | 本仓库式 `*/SKILL.md`、Claude `skills/`、或各产品文档中的「项目级说明」 |
| Hooks / 自动化 | `.cursor/hooks.json`、各 IDE 任务与扩展钩子（以产品为准） |
| MCP / 工具 | `.cursor/mcp.json`、Continue 配置、Claude `settings.local.json` 等 |
| 密钥与本地覆盖 | `.env`、`*.pem`、各宿主 `settings.local`、勿入库 |

## 边界

- **查配置与协作栈**，不查业务逻辑是否正确。
- **不自动改文件**；`Action:` 只给可复制命令或明确编辑说明，由用户确认后执行。

## 输出语言

优先遵守项目内 **沟通约定**（`AGENTS.md`、`CLAUDE.md`、Copilot 说明、各平台 rules 中的语言要求）；否则跟随用户当前语言。

## 预算与深度

- **默认摘要**：`collect-context.sh` + 抽样读关键文件 + MCP 列表与无害探活（若可做）。
- **深检**：用户要求「彻底/完整/深入」或出现 `[!]` 时再展开；**事先说明**耗时与 token。

## Step 0：项目量级（对齐期望）

| 层级 | 信号 | 期望（可放宽） |
|------|------|----------------|
| **Simple** | 小仓库、无 CI | 有 README 或 AGENTS；规则 0–1 份即可 |
| **Standard** | 有 CI 或小团队 | README + 仓库级规则；MCP/工具清单清晰 |
| **Complex** | 多包、多 MCP、hooks 多 | 规则分层、技能可发现、工具最小权限、密钥不入库 |

**勿用 Complex 标准卡 Simple 项目。**

## Step 1～4（细节在 health-methods）

- **Step 1 事实**：仓库通用项 + 按宿主补充；优先使用 **`scripts/collect-context.sh`** 输出。
- **Step 2 MCP**：无害探活、`enabled: false` 跳过；报告不贴完整 key。
- **Step 3 规则与技能**：矛盾、重复、过度全局、本仓库各 `SKILL.md` 的 `name`/`description` 质量。
- **Step 4 报告**：按下表输出。

```text
Health Report: {项目名} ({Simple|Standard|Complex}，宿主：…)

### Facts（摘录 collect-context 或等价收集）

### [PASS]（表格，≤5 行）

### Finding
- [severity] 症状（文件:行 若可知）
  Why: 一行原因
  Action: 可复制命令或具体编辑说明
```

**严重度**：`[!]` 密钥/危险 allowedTools / MCP 滥用；`[~]` 分层与重复；`[-]` 卫生与文档。

无问题时：`All relevant checks passed. Nothing to fix.`

## Gotchas

| 情况 | 处理 |
|------|------|
| 未装 `python3`/`jq` | `collect-context.sh` 会标注 `json_skip`；**不**当缺陷，除非项目依赖 JSON CI |
| Hook「没触发」 | 先查宿主 debug / UI 遮挡，再怀疑配置 |
| 与 Waza 混用 | Claude Code 可并行跑上游 `collect-data.sh`；本仓库不假设其存在 |
