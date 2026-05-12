---
name: read
description: 将 URL 或 PDF 转为干净 Markdown，便于引用、存档或下游 learn/write。用户给出链接、读网页、抓取文章、看 PDF 内容时使用。优先运行本技能目录下 scripts；不用于仓库内已有文本文件（直接 Read 工具即可）。
---

# Read：URL / PDF → Markdown

本技能 **`read/scripts/` + `read/references/read-methods.md` 自包含**，路径与命令均以本仓库为准。

首条回复可在句首内联加 `🥷`。

## 执行前必读

打开并遵循：

**[`read/references/read-methods.md`](references/read-methods.md)**

其中含：代理链顺序、`read-url.sh` / `pdf-extract.sh` / `save-md.sh` 用法、付费墙、微信/飞书/X、与 MCP 的配合。

## 路径约定

- 若当前工作区为本仓库根目录：`READ_ROOT` = `read`（相对路径）或绝对路径 `.../zhijunio-skills/read`。
- 抓取命令示例：

```bash
bash read/scripts/read-url.sh "https://…"
```

## 边界

- **默认只做转换**：不主动总结、不延伸解读，除非用户在抓取后**明确**要求。
- **本地仓库非 PDF 文本**：用编辑器 Read，不走本 skill。

## 路由摘要（细节以 read-methods 为准）

| 场景 | 做法 |
|------|------|
| 通用 URL | `read-url.sh`（defuddle → jina → curl） |
| 微信公众号 | `read-url.sh`（**jina → defuddle**，弱化误杀付费墙） |
| 飞书 / Lark | 已设 `FEISHU_APP_*` 时 **`fetch_feishu.py`**；否则 jina/defuddle 兜底（易失败） |
| GitHub blob | 脚本内 raw + 可选 `gh` |
| 本地/远程 PDF | `pdf-extract.sh` 或 `read-url.sh` 内 PDF 分支 |
| 强反爬 / 重 JS | 已配置的 **Firecrawl 等 MCP** 优先于脚本 |

## 输出格式（建议）

```text
Title:  {title}
Author: {author 若有}
Source: {站点或类型}
URL:    {原始链接}

Content
{Markdown 正文；过长可先截断并注明「以下截断至前 N 行/字」}
```

## 保存

- **默认**：只在对话里展示 Markdown，**不新建文件**。
- 用户说 **保存 / download / 下载**，或从 **`learn`** Phase 1 需要落盘时：`read-url.sh` 管道到 `save-md.sh`（见 read-methods §3）。
- 未保存时不必强调「我没写文件」。

## 图片

默认不批量下图。用户明确要求「带图 / 下载图片」时，再从 Markdown 中提取图片 URL 下载到单独目录，并报告成功/失败 URL。

## Gotchas

| 情况 | 处理 |
|------|------|
| 用户说「读一下」其实要总结 | 先交付 Markdown，再问是否需要摘要 |
| 返回的是 JSON | 抽取正文字段再展示 |
| 内容过长 | 截断并说明；或只展示 `head -n 200` 预览 |

## 与 `learn` 的配合

多源研究时每条 URL 用本 skill；落盘命名与 `learn` Phase 1 一致即可。
