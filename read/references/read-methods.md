# Read 方法参考（本仓库）

执行抓取前请先读本文件。脚本根目录：

`READ_ROOT` = 本仓库内 `read/`（即含 `scripts/`、`references/` 的目录）。

## 1. 一键抓取（推荐）

对 **http(s) URL** 或 **本地 `.pdf` 路径**：

```bash
bash "${READ_ROOT}/scripts/read-url.sh" "https://example.com/article"
```

成功时 stdout 为正文（常为 Markdown）；失败时 stderr 有说明，退出码非 0。

**GitHub**：`raw.githubusercontent.com` 直连；`github.com/.../blob/...` 自动换 **raw**；若 404 且已装 `gh` 并登录，会尝试 **private raw**（`Accept: application/vnd.github.raw`）。

**远程 PDF**：先试 `r.jina.ai`；失败则下载到临时文件再 `pdf-extract.sh`。

**通用网页**：`defuddle.md` → `r.jina.ai` → 直连 `curl`（见 `read-url.sh` 内顺序）。

## 2. 仅抽取本地 PDF

```bash
bash "${READ_ROOT}/scripts/pdf-extract.sh" "/path/to/file.pdf"
```

依赖（任一即可）：

- **poppler**：`pdftotext`（如 `brew install poppler`）
- 或 **Python**：`pip install -r "${READ_ROOT}/scripts/requirements-read.txt"`（`pypdf`）

## 3. 保存到 ~/Downloads

stdin 写入 Markdown 文件（与 `learn` Phase 1 落盘配合）：

```bash
bash "${READ_ROOT}/scripts/read-url.sh" "https://example.com/page" \
  | bash "${READ_ROOT}/scripts/save-md.sh" "example-page"
```

`save-md.sh` 参数为 **文件名 slug**（仅字母数字 `._-`，其它会替换为 `_`）。已存在则自动 `-1`、`-2`，不覆盖。

保存后脚本会 **打印最终绝对路径**（一行）。

## 4. 代理链与付费墙

- 若正文前几十行出现 Subscribe / Sign in / 登录后阅读 / 付费等，`read-url.sh` 会判为失败并尝试下一跳；全部失败则退出 1。
- **不要把登录页当正文保存**；若用户仍要存档，在文件头用 HTML 注释注明「疑似付费墙」。

## 5. 微信 / 飞书 / X

### 微信公众号 `mp.weixin.qq.com`

- **支持（尽力而为）**：`read-url.sh` 对微信 **优先 `r.jina.ai`，再 `defuddle.md`**；正文里常有「登录」类广告，脚本 **不用通用付费墙规则** 误判（见 `read-url.sh` 内 `weixin_nonempty_ok`）。
- **不保证**：反爬、仅登录可见、已删除文章会失败。
- **兜底**：已配置的 **Firecrawl MCP**、或浏览器打开后复制正文 / 导出 PDF，再走 `pdf-extract.sh` 或粘贴给 Agent。

### 飞书 / Lark `feishu.cn`、`larksuite.com`

- **支持（需自建应用）**：若已设置环境变量 **`FEISHU_APP_ID`**、**`FEISHU_APP_SECRET`**，且应用具备 **`docx:document:readonly`**、**`wiki:wiki:readonly`**，`read-url.sh` 会优先调用 **`scripts/fetch_feishu.py`** 拉取 **docx**，或 **wiki 节点指向的 docx**。
- **依赖**：`pip install requests`（已写入 `scripts/requirements-read.txt`）。
- **不支持**：旧版 **`/docs/`** 链接（请在飞书里转为 **docx** 再分享）。
- **未配置凭证时**：与普通网页一样走 jina / defuddle（飞书网页常需登录，**成功率低**），建议配置 API 或用 MCP / 导出。

```bash
export FEISHU_APP_ID=cli_xxx
export FEISHU_APP_SECRET=xxx
bash "${READ_ROOT}/scripts/read-url.sh" "https://xxx.feishu.cn/docx/AbCdEfGh"
# 或直接：
python3 "${READ_ROOT}/scripts/fetch_feishu.py" "https://..."
```

### X / Twitter

| 场景 | 本仓库脚本 | 说明 |
|------|------------|------|
| X / Twitter | `read-url.sh` | 常失败或空壳；不要编造正文 |

## 6. Agent 侧：MCP 优先

若当前环境已配置 **Firecrawl** 或其它抓取 MCP，且效果优于 `read-url.sh`（重 JS、强反爬），**先用 MCP**，脚本作为回退与可复现流水线。

## 7. 输出包装（约定）

在 stdout 正文外，由 Agent 为用户加头（脚本不强制写头）：

```text
Title:  （可从正文首行或 <title> 推断）
Author: （若有）
Source: web | github | pdf
URL:    原始链接

Content
{read-url.sh 或 MCP 的输出}
```

## 8. 故障排查

| 现象 | 处理 |
|------|------|
| `defuddle` / `jina` 全空 | 试直连 curl；再试 MCP；仍失败则如实报告 |
| GitHub private 拉不下来 | `gh auth login` 后重试 |
| PDF 报缺依赖 | 安装 poppler 或 `pip install -r scripts/requirements-read.txt` |
| URL 含 `&` | 调用脚本时 **务必给 URL 加引号** |

## 9. 自包含说明

本目录与 `read/scripts/` 均以本仓库为准维护；与宿主内其它抓取/技能路径无绑定关系。
