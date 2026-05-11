# Health 方法参考（本仓库）

审计 **AI 协作栈**（项目说明 → 规则 → 技能 → hooks/自动化 → 工具/MCP → 密钥卫生）时，先读本文件再按 **摘要 / 深检** 执行。边界与报告格式以上级 **`health/SKILL.md`** 为准。

本 skill 设计为 **多 Agent 平台通用**：先根据 **仓库内标记文件 + 用户声明** 判断当前主要宿主，再只深入相关路径；**禁止**假设全队只用 Cursor。

## 1. 摘要 vs 深检

| 模式 | 何时 | 做什么 |
|------|------|--------|
| **摘要**（默认） | 用户未要求「彻底/完整/深入」 | 跑 `collect-context.sh`、看 **`## agent_markers`**、抽样读 1–3 个规则入口、列 MCP、输出 Findings |
| **深检** | 用户明确要求，或摘要发现 `[!]` / 控制面无法判定 | 全文读规则与 hooks、逐 MCP harmless 探活、按 **该产品当前文档** 开 debug；事先说明耗时 |

**勿用** Complex 标准卡 Simple 仓库（见 `SKILL.md` Step 0）。

## 2. 识别宿主（必做）

在报告 **首段** 写清：

1. **用户声明**：当前主要使用的 Agent（可多选：如 Cursor + Copilot）。
2. **仓库标记**：对照下面 **平台标记表** 与 `collect-context.sh` 输出的 **`## agent_markers`**（`yes` 多说明可能多宿主并存）。
3. **结论行**：`primary=…`，`also_present=…` 或 `ambiguous → 已询问用户`。

**无法读取用户主目录时**（如 `~/.codex`、`~/.continue`）：在 Finding 里写 **「需用户本地贴出目录树或脱敏配置」**，不要猜。

### 2.1 平台标记表（仓库根 `$ROOT`）

以下路径 **存在即可能在使用该平台**（以各产品最新文档为准；版本迭代时以官方为准）。

| 平台（常见名） | 仓库内常见标记 | 用户级（若审计环境可读） |
|----------------|----------------|---------------------------|
| **Cursor** | `.cursor/rules/`、`.cursor/mcp.json`、`.cursor/hooks.json` | Cursor 应用内设置 |
| **Claude Code** | `CLAUDE.md`、`.claude/rules/`、`.claude/settings.local.json` | `~/.claude/` |
| **Codex CLI** | `AGENTS.md`（仓库） | `~/.codex/AGENTS.md` |
| **GitHub Copilot**（VS Code / JetBrains 等） | `.github/copilot-instructions.md`、`AGENTS.md`、`.github/instructions/` | 各 Editor「Copilot / AI」设置 |
| **Continue** | 项目内 `.continue/`（若有）、或与 `AGENTS.md` 共用 | `~/.continue/config.json` 等 |
| **Windsurf** | `.windsurfrules`（单文件常见） | Cascade / 应用内规则 |
| **Cline / Roo Code** | `.clinerules`、`.roomodes` | 扩展设置 |
| **Amazon Q Developer** | `.amazonq/rules/` 等 | Q 配置 |
| **Aider** | `.aider.conf.yml`、`CONVENTIONS.md` | `~/.aider.conf.yml` |

**无标记且用户未声明**：`primary=unknown`，只做 **§4 仓库通用** + 询问用户常用 Agent。

## 3. 一键收集（推荐第一步）

```bash
bash /path/to/zhijunio-skills/health/scripts/collect-context.sh "$ROOT"
```

本仓库自检：

```bash
bash health/scripts/collect-context.sh "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

输出含 **`## agent_markers`**（多平台标记）、**`## paths_present`**（Cursor/Claude 等核心路径）、**`skill_md_index`**。只读、不 `cat` 敏感文件内容。

## 4. 仓库通用检查（与宿主无关）

### 4.1 入口文档

- [ ] `README.md` 是否存在且非空（Simple 至少说明如何跑/测）。
- [ ] `AGENTS.md` 或 `CLAUDE.md` 是否存在（Standard+ 建议有其一；**多 Agent 团队**可两段各写适用产品）。

### 4.2 Git 卫生（只列路径）

```bash
git -C "$ROOT" status -sb 2>/dev/null || true
git -C "$ROOT" ls-files 2>/dev/null | grep -Ei '(^|/)\.env($|[.])|(^|/)id_(rsa|ed25519)|(^|/)\.pem$|settings\.local\.json|(^|/)\.npmrc$|(^|/)\.pypirc$' || true
```

被追踪的 `.env` / 私钥 / `settings.local.json` → 通常 `[!]`。

### 4.3 CI / 体量

```bash
test -d "$ROOT/.github/workflows" && echo has_ci=yes || echo has_ci=no
```

## 5. Cursor（标记存在时深入）

| 检查项 | 做法 |
|--------|------|
| 规则 | `ls` `.cursor/rules`；与 `AGENTS.md` / `CLAUDE.md` 是否重复或矛盾 |
| MCP | `.cursor/mcp.json` JSON 合法、`enabled: false` 不误判 |
| Hooks | `hooks.json` 内脚本路径、是否拉远程未校验脚本 |

## 6. Claude Code

| 检查项 | 做法 |
|--------|------|
| 规则 | `.claude/rules/` vs `CLAUDE.md` |
| 本地覆盖 | `.claude/settings.local.json` 是否误提交 |
| 深检 | 可选 [Waza collect-data.sh](https://github.com/tw93/Waza/tree/main/skills/health) |

## 7. Codex CLI

- 仓库 `AGENTS.md` vs `~/.codex/AGENTS.md` 块是否 **重复、语言冲突**。

## 8. GitHub Copilot / Editor 内嵌 AI

- `.github/copilot-instructions.md`、`.github/instructions/` 是否与 `AGENTS.md` / `.cursor/rules` **同一条款重复三遍** → `[~]` 合并到单一事实来源。
- 指令是否含 **禁止泄露的路径/密钥示例**（应用 `[!]` 若示例像真密钥）。

## 9. Continue

- 若存在项目 `.continue/` 或用户可读 `~/.continue/`：MCP / model 配置是否与仓库规则一致；**勿**打印 API key。

## 10. Windsurf

- `.windsurfrules` 体量与分段；与 `AGENTS.md` 是否矛盾。

## 11. Cline / Roo Code

- `.clinerules` / `.roomodes` 是否与 Cursor rules 或 `AGENTS.md` 冲突。

## 12. Amazon Q

- `.amazonq/rules/` 与团队其它规则入口是否一致。

## 13. Aider

- `.aider.conf.yml` 是否把密钥写进仓库；`CONVENTIONS.md` 是否与 `AGENTS.md` 打架。

## 14. MCP 探活（任一平台声明了 MCP 时）

对每个 `enabled != false` 的 server：无害探活；报告 **不**贴全 key。

## 15. Hooks

未触发先查产品 debug / UI 遮挡，再判配置坏。

## 16. 技能仓库（如 `zhijunio-skills`）

各 `*/SKILL.md` 的 `name` / `description`；链式技能（read → learn → write）是否互相指向本仓库路径。

## 17. Finding 规范

`Action:` 必须可复制；无法给命令时给 **复现步骤 + 官方文档链接**。

## 18. 非目标

不审业务逻辑；不自动改文件。

## 19. 思路来源

曾对照 [Waza health](https://github.com/tw93/Waza/tree/main/skills/health)（MIT）；多平台表为自维护，**以各产品最新文档为准**。
