# zhijunio-skills

面向 **Cursor** 等 AI 编程助手的 **Agent Skills** 合集：每个技能一个目录，核心说明在 **`SKILL.md`**（YAML 的 `name` / `description` 供宿主发现与触发）。部分技能附带 **`references/`** 操作细则与 **`scripts/`** 可执行脚本，便于复现与离线流水线。

## 技能一览

| 目录 | 作用摘要 |
|------|-----------|
| [**bookmark**](bookmark/SKILL.md) | 将链接保存为本地 Markdown 书签（标题、标签、去重）。 |
| [**diary**](diary/SKILL.md) | 日记落盘：路径、时间戳、图片、`DIARY_VAULT_ROOT` 与 Git 流程。 |
| [**health**](health/SKILL.md) | 多 Agent 平台下的协作栈体检（规则、MCP、hooks、密钥卫生）；含 `scripts/collect-context.sh` 与 `references/health-methods.md`。 |
| [**jinrishici**](jinrishici/SKILL.md) | 调用今日诗词接口，按固定中文格式展示诗句与作者、篇名。 |
| [**keep**](keep/SKILL.md) | Keep 跑步数据同步为 Garmin 风格 `running.json`（脚本在 `keep/scripts/`）。 |
| [**learn**](learn/SKILL.md) | 多源材料 → 结构化长文 / Canonical 参考；与 **read**、**write** 链式配合。 |
| [**read**](read/SKILL.md) | URL / PDF → Markdown；`read-url.sh`、飞书 Open API、微信/代理链等见 `read/references/`。 |
| [**write**](write/SKILL.md) | 去 AI 味、中英润色、双语/发版/社媒/审稿；词表在 `write/references/`。 |

## 技能之间的关系（可选链式）

```text
read（抓取） → learn（研究写作六阶段） → write（去味定稿）
                    ↘
                 health（配置与仓库卫生审计）
```

- **learn** 的 Phase 1 抓取建议走 **read** 的脚本与 `read-methods.md`。  
- **learn** 的润色阶段可交给 **write**。  
- **health** 独立使用，用于审计当前项目或本仓库自身的规则/MCP/敏感文件路径。

## 如何使用

1. 在 Cursor（或支持你所用 **Skills 机制** 的宿主）中，将本仓库路径加入 **Skills / 技能** 配置，使各 `SKILL.md` 被索引。  
2. 依赖对话触发：宿主通常根据 **`description`** 与当前用户请求匹配技能；也可在提示里显式指明技能名或目录。  
3. 带脚本的技能（如 **read**、**health**、**keep**）在 `SKILL.md` 内写有 **推荐命令**；请在目标机器上自行安装脚本依赖（如 `bash`、`python3`、`requests` 等）。

## 目录约定

```text
<skill>/
  SKILL.md           # 入口：name、description、边界与硬规则
  references/        # 可选：分场景说明、检查清单
  scripts/           # 可选：shell / Python 等
```

## 维护与依赖

- 根目录 **`renovate.json`** 用于依赖与配置的自动更新提案（若已接入 Renovate）。  
- 部分技能思路曾对照开源项目（如 [Waza](https://github.com/tw93/Waza)），在对应 `SKILL.md` 或 `references` 中已标注；本仓库实现以各目录内文件为准。

---

若你希望补充 **许可证**、**安装截图** 或 **CI 校验 SKILL  frontmatter**，可在 Issue 中说明需求边界。
