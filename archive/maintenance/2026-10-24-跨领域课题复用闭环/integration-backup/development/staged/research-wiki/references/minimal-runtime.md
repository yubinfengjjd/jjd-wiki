# 最小运行清单与独立性证据

本页定义方法实现和单 panel 模板共用的 `runtime.json`。事实只由 `rwiki/runtime_contract.py` 解析；API、`lint`、`check-entry`、代码查看器与前端读取同一结果。

## 文件位置

```text
methods/<method-id>/runtime.json
methods/<method-id>/verification/<implementation-id>-portability.json
templates/<template-id>/runtime.json
templates/<template-id>/verify/runtime-portability.json
```

`runtime.json` 和证据都在条目资产根内，不允许绝对路径、`..`、隐藏段、反斜杠或符号链接逃逸。API 只读，不扫描课题目录，也不检查服务器已装包。

## 清单字段

方法（多个分支）：

```json
{
  "schema_version": 1,
  "kind": "method",
  "id": "cell-quality-control",
  "implementations": [
    {
      "id": "scp-runcellqc",
      "entry": "code/analysis.R",
      "entry_function": "run_cell_quality_control",
      "language": "R",
      "runtime_mode": "standalone",
      "files": ["code/analysis.R", "code/cellqc_native.R", "code/data/palette_list.rda"],
      "resources": [
        {"path": "code/data/palette_list.rda", "sha256": "<64 hex>", "role": "optional plot palette"}
      ],
      "required_packages": {"R": ["Seurat", "SeuratObject", "Matrix", "rlang"]},
      "optional_packages": {"R": {"scDblFinder": "doublet branch when qc_metrics includes doublets"}},
      "python": [],
      "source": {
        "package": "SCP-local", "version": "0.5.6",
        "commit": "b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0",
        "license": "GPL (>= 3)",
        "functions": ["R/SCP-cellqc.R:RunCellQC"],
        "modifications": ["check_R replaced with a fail-only guard"]
      },
      "evidence": {"portability": "verification/scp-runcellqc-portability.json"}
    }
  ]
}
```

模板用同一个对象结构，`kind` 为 `template`，根上直接放 `entry`、`files` 等字段，没有 `implementations` 数组；`entry_function` 可省略。

字段约束：

- `runtime_mode`：`standalone`（清单闭包可独立运行）、`bundle`（仍需完整来源库）、`unknown`（历史未审计）。
- `files` 必须包含入口，且每个文件真实存在；不允许重复。
- `required_packages` / `optional_packages` 只写包名和用途，不写安装状态；跨语言实现用语言键区分（如 `{"R": [...], "Python": ["scanpy", "numpy", "scvelo"]}`），前端按语言显示归属。可选包只在对应功能启用时检查。不要另写一个 `python` 必需包字段，避免两套事实。
- `resources` 是本模块携带的数据/资源（例如 palette `.rda`），必须给用途；每个资源必须同时列入 `files`，并提供与当前字节一致的 `sha256`。只写 resources、不写 files 等同于未绑定闭包，清单应拒绝。
- 清单 `entry` 与 `entry_function` 必须与页面 `implementations[].entrypoint` 的路径和函数一致；入口文件必须真的定义该函数（允许 `name <- function` 或私有闭包 `name <- local({ ... })`）。不一致时独立性证据为 invalid，不能沿用另一个入口的 verified。
- `source.functions` 记录原函数位置；`modifications` 只写为独立运行所做的兼容改动，不把算法改写混进去。

## 独立性状态

| 状态 | 含义 |
|---|---|
| `verified` | 只复制清单文件和资源到异目录，不提供来源库路径，新进程实际调用通过 |
| `declared` | 只有 standalone 声明，没有独立性收据 |
| `not_run` | 已复制并执行到精确的缺依赖或上游失败，未通过 |
| `stale` | 清单、入口、helper、资源或依赖声明变化，旧证据不再绑定当前闭包 |
| `invalid` | 收据路径/字段/指纹/覆盖范围不合法 |
| `bundle` | 明确仍需完整来源库 |
| `unknown` | 没有清单，历史未审计 |

`verified` 只说明“可脱离来源库运行”，不说明算法正确、科学有效或适合任意课题。算法状态仍由 `verification/*.json` 的 `state` 决定，两者分别显示。

## 独立性收据

```json
{
  "schema_version": 1,
  "kind": "method",
  "implementation": "scp-runcellqc",
  "state": "passed",
  "scope": "异目录复制、新进程、不提供 SCP-local 路径；80 个示例细胞",
  "closure_hash": "<runtime.json + 清单文件的 sha256>",
  "files": {"code/analysis.R": "<sha256>", "code/cellqc_native.R": "<sha256>"},
  "copied_files": ["code/analysis.R", "code/cellqc_native.R"],
  "command": "Rscript --vanilla <isolated>/code/analysis.R ...",
  "environment": {"R": "4.5.0", "BPPARAM": "BiocParallel::SerialParam()", "future": "sequential"},
  "checks": ["复制到异目录", "新进程实际调用", "输入未修改"],
  "executed_at": "2026-10-23T00:00:00+00:00"
}
```

失败时 `state` 写 `not_run`，`scope` 或 `not_run_reason` 写精确错误。不要用假引擎、只 source 不调用、只跑一个分支或旧整库收据填写 `passed`。

收据必须来自实际运行：`command` 写含实际代码目录、case、输入/输出路径的完整可重放命令；`case` 写实际参数；`input_sha256`/`output_sha256` 与 `files` 写执行时哈希。算法 `passed` 另有实际比较/断言产物（如 `comparison.json`），缺少比较、命令缺失或输出失败时只能是 `not_run`，不得由生成脚本硬编码。

`resources`、`source`、`required_packages`、`optional_packages`、`evidence` 等容器类型错误必须返回具体 issue；`runtime_facts` 不得抛异常导致页面 500。

## 操作顺序

1. 提炼时确定闭包，写 `runtime.json` 和文件/资源。
2. 在同一环境做算法对照（原版 vs 新模块，同输入同参数）。
3. 复制清单文件/资源到维护记录的异目录，新进程、不提供来源库路径，实际调用。
4. 写独立性收据；算法收据另写，两套 `files` 都覆盖当前代码。
5. `lint` 与 `check-entry` 核对；清单/代码变更后重跑并更新证据，旧证据保留。

## 模块封装与加载边界

- 入口写成 `name <- local({ ... function(...) ... })`，engine、helper、包检查和分支选择都在该闭包内；source 只暴露 `name`，不暴露 `.scp_impl/.scp_run` 等通用名。多个模块 source 到同一环境后，先前模块的入口仍使用自己的引擎。
- 模块目录取当前被 source 文件（从最内层 frame 的 `ofile` 开始查），不能取外层课题 driver；不支持 `sys.source` 无 `ofile` 时，使用 `chdir=TRUE` 或显式说明限制。
- 调用前后保存 `search()` 与 `options()`；只 detach 本次新增的包，按依赖逆序重试；不 detach 用户原有包，不 unload namespace。成功和异常路径都验证，diagnostics 写实际 `search_restored/options_restored`。

## 与入库八步的关系

- 第 5 步（提炼）产出 `runtime.json` 和复制清单。
- 第 6 步（验证）同时产出算法对照与独立性收据；缺包保持 `not_run`。
- 第 8 步（验收）核对算法与独立性两个轴，不能互相代替。

细节规则以总库 `AGENTS.md` 为准。
