# Release notes / Changelog

## 准备

1. 读项目已有 **`CHANGELOG.md`**、**`README`** 或 **`AGENTS.md` / `CLAUDE.md`** 里关于发版的约定。
2. 若有 GitHub：`gh release view --json body -R owner/repo` 取 **最近一条** 作篇幅、语气、条目密度参考。
3. **Breaking** 必须显眼；内部重构若无用户可见行为，可放进 Fixes 或不写。

## 结构（按项目习惯裁剪）

建议块（中英可并列一句时，先用户影响再技术细节）：

- **Breaking changes** / **破坏性变更**
- **New features** / **新功能**
- **Fixes & improvements** / **修复与改进**
- **Deprecations** / **弃用说明**

## 每条怎么写

- **一句用户视角**：「修了什么现象 / 多了什么用法」，避免纯 PR 标题堆砌。
- **编号或列表**与历史 release **对齐**（不要突然从段落体改成小论文体）。
- **不编造版本号与日期**；用户未给 tag 时写「待发布」或留空位。

## 双语发版（常见需求）

- 每条 **先中文后英文一句**，或 **英文一句 + 中文一句**，全篇统一一种结构。
- 术语表（产品名、CLI 子命令）两边一致。

## 不要写进 release 的

- 长篇架构愿景、与版本无关的 roadmap（除非用户明确要）。
- 无 ticket/无 PR 佐证的「性能大幅提升」（除非有可引用 benchmark）。
