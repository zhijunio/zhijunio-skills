# Write 方法参考（本仓库）

改稿前先读本文件，再按 **被编辑文本**（不是用户指令语言）加载下表对应 reference，读完再改。

## 1. 加载路由

| 文本与任务 | 必读 reference |
|------------|----------------|
| 以中文为主的一般正文 | [`write-zh.md`](write-zh.md) |
| 以英文为主的一般正文 | [`write-en.md`](write-en.md) |
| 中英混排、双语对照、翻译审校 | [`write-bilingual.md`](write-bilingual.md)，必要时叠加 `write-zh.md` / `write-en.md` |
| Release / changelog / 发版说明 | [`write-release-notes.md`](write-release-notes.md) |
| 推特 / X / 社媒短文 | [`write-social.md`](write-social.md) |
| 白皮书 / 长文档审稿（含隐私扫描） | [`write-document-review.md`](write-document-review.md) |
| 仅要段落连贯诊断、不要求全文重写 | [`write-document-review.md`](write-document-review.md) 末尾「段落连贯」节 |

若用户同时要求多种模式（例如「双语发版说明」），按上表 **自上而下合并规则**，冲突时以 **意思不变、就地编辑、少 meta** 为准（见上级 `SKILL.md` 硬规则）。

## 2. 与上级 `SKILL.md` 的关系

- **硬规则、边界、输出约定** 以仓库内 **`write/SKILL.md`** 为准。
- 本目录只补充：**可执行的检查清单、词表、模式说明**，避免把 `SKILL.md` 撑成超长单文件。

## 3. 外部链接（不随仓库同步正文）

- 中文排版：[中文文案排版指北](https://github.com/mzlogin/chinese-copywriting-guidelines)

## 4. 思路来源

部分结构曾对照 [tw93/Waza — skills/write](https://github.com/tw93/Waza/tree/main/skills/write)（MIT）；本目录为 **自包含改写**，不依赖 Waza 仓库路径。
