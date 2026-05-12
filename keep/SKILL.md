---
name: keep-running-json
description: 通过 Keep Open API 登录并拉取跑步记录，生成与 Garmin 脚本兼容的 running.json（含 VDOT、训练负荷、周期统计、可选每公里分段）。在用户提及 Keep 跑步同步、fetch_keep_run、running.json 或从 Keep 导出跑步数据时使用。
---

# Keep 跑步数据同步

指导如何运行本仓库内的 **[`scripts/fetch_keep_run.py`](scripts/fetch_keep_run.py)** 拉取 Keep 跑步数据并生成 **`running.json`**。

## 何时使用

- 用户要从 **Keep** 导出跑步记录并与既有 **Garmin 风格** 统计格式对齐。
- 用户提到 **`fetch_keep_run.py`**、**`running.json`**、**Keep API**、**VDOT** / **训练负荷**。
- 需要说明脚本依赖、环境变量、输出路径或调试方式。

脚本已置于本技能目录 **`keep/scripts/fetch_keep_run.py`**，与上游 **[zhijunio.github.io/scripts/fetch-keep-run.py](https://github.com/zhijunio/zhijunio.github.io/blob/main/scripts/fetch-keep-run.py)** 对齐；后续以该文件为准同步。

## 脚本职责（摘要）

1. 使用手机号 + 密码调用 Keep 登录接口，取得 session。
2. 分页拉取跑步记录，支持**增量**（遇已有 `startTime` 停止）与 **`--full` 全量**。
3. 若输出文件已存在则**合并**已有 `runs`（按 `startTime` 去重，新数据优先），并重算 `stats`。
4. **展示时间与周期统计按上海时区**（`UTC+8`）写入。

## 依赖

- **Python 3**
- **`requests`**

安装示例：

```bash
pip install requests
# 或：pip install -r keep/scripts/requirements.txt
```

## 凭证与环境变量

| 变量 | 含义 |
|------|------|
| `KEEP_MOBILE` | Keep 登录手机号（可用 `--mobile` 覆盖） |
| `KEEP_PASSWORD` | 密码（可用 `--password` 覆盖） |
| `MAX_HR` | 最大心率，默认 `180`（VDOT/心率区间） |
| `RESTING_HR` | 静息心率，默认 `55` |
| `RUNNER_WEIGHT_KG` | 体重（kg），用于本地估算功率，默认 `70` |

不要在对话或日志中复述用户密码； credentials 仅通过环境变量或本地 CLI 传入。

## 命令行

`--output` 为**相对脚本所在目录**的路径。上游默认 **`../public/data/running.json`**（适配个人站 Jekyll 布局）；在本 skills 仓库中请**显式指定**输出路径，例如：

```bash
python keep/scripts/fetch_keep_run.py \
  --mobile "$KEEP_MOBILE" \
  --password "$KEEP_PASSWORD" \
  --output data/running.json
```

若在 `keep/scripts/` 下执行：`python fetch_keep_run.py ... --output data/running.json`。

常用参数：

| 参数 | 说明 |
|------|------|
| `--output` | 输出文件（相对脚本目录）；默认 `../public/data/running.json` |
| `--full` | 全量拉取并合并，忽略增量早停 |
| `--limit N` | 最多获取 N 条（调试用安全上限） |
| `--debug` | 打印请求与转换细节 |

## 输出结构要点

- **`stats`**：总距离/时长/配速、VDOT、训练负荷、`period_stats`（昨日/周/月/年/累计）、`statistics_time`（上海时间）等，以脚本内 `_calculate_stats` 为准。
- **`runs`**：每条含 **`startTime` / `endTime`**（上海本地时间字符串）、`distance`（km）、`duration`、`averagePace`、`averageHeartRate`、**`vDOT`**、**`trainingLoadScore`**、**`heartRateZone`**、**`segments`** 等；字段名与上游 `running.json` 消费端保持一致。

若目标 `running.json` 已存在：脚本会读入其中 **`runs`**，与本次拉取按 **`startTime`** 合并去重后写回并重算 **`stats`**；`--full` 时走全量拉取逻辑（见脚本内注释）。

## Agent 操作建议

1. 确认用户已安装依赖且能访问 Keep API（网络环境）。
2. 优先使用环境变量传入凭证，避免将密码写入仓库或聊天。
3. 首次排查接口或字段问题时，建议 `--limit 1 --debug`。
4. 若用户需与 **Garmin 导出脚本** 混用同一 `running.json`，保持字段名与 `format_running_data` 输出一致，不要私自改键名。