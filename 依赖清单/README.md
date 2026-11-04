# 新电脑依赖目录与批量安装入口

本目录汇总现有 runtime 声明、配方实际加载的包、SCP/scop 来源声明及 L0 归档候选。目标电脑可先统一准备环境、整批安装，再运行分析。2026-11-04 已在独立 Wiki R 4.5.0、Wiki Python、ML Python 和旧 SCP Python 环境完成本轮准备与逐项复跑；实际范围及缺口见[审查记录](../维护记录/2026-11-03-待运行代码审查/task_plan.md)。依赖声明和安装存在性均不等于算法验证。

## 先用哪些文件

| 文件 | 用途 |
|---|---|
| `packages.tsv` | 去重总表：语言、包、所属分支、待运行范围、安装来源、版本快照 |
| `R/runtime.txt`、`R/plan.tsv` | 当前执行入口及原生函数目录、已提升配方的直接/可选依赖；默认批量安装范围 |
| `R/pending.txt` | 迁移清单中 34 个待验证分支涉及的包，以及批量安装工具依赖 |
| `R/all.txt` | 扩展到尚未提升的 L0 条目与来源 Suggests；按需整批安装 |
| `R/unresolved.tsv` | 来源尚未明确或当前仓库未提供的候选；保留用途与引用，不猜替代包 |
| `R/observed-versions.tsv` | 旧电脑实际存在的相关版本，供对照；不等于可恢复的完整锁文件 |
| `python/*.requirements.txt` | 各 Python 环境的一次性 pip 输入 |
| `python/wiki.requirements.lock.txt` | 界面环境现有锁文件的逐字节副本 |
| `python/scp-legacy-profiles.json` | 原 SCP 的五套版本组合与其真正声明的 Python 版本 |
| `python/scop-upstream-constraints.tsv` | scop 源码中的固定版本候选，供按模块选型；不能合并为一个 pip 环境 |
| `node-direct.tsv` | 前端直接依赖；全部间接版本以 `开发/frontend/package-lock.json` 为准 |
| `system-tools.tsv` | Python、R、编译工具、Java等系统级前置条件及官方来源 |
| `manifest.json`、`repository-snapshot.json` | 覆盖范围、输入哈希、已查询的仓库信息与 GitHub 固定提交 |

计数以 `manifest.json` 为准。R 总表同时包括运行依赖与来源候选，不能把总行数当作每次分析都需要的包数；间接依赖由安装器解析。没有明确来源的条目会集中报告，其他可解析条目继续安装。

## 环境与版本边界

| 环境 | 基线与范围 |
|---|---|
| Wiki 界面 | Python 3.12，使用现有锁文件 |
| UC/哮喘机器学习 | 独立 Python 3.12 环境，`ml.requirements.txt`；新机解析依赖后保存 pip freeze，不能冒充旧机精确环境 |
| 旧 SCP 0.5.6 后端 | 单独 Python 3.8 环境，优先按原声明的 `3.8-2` 组合准备；它包含 scanpy 1.9.5、scvelo 0.2.5 等固定请求。完整间接依赖仍需解析 |
| 现代单细胞候选 | 单独环境使用 `singlecell-modern.requirements.txt`，不得覆盖旧 SCP；它不等于已验证的旧 SCP 替代环境 |
| irGSEA Python 可选后端 | `irgsea-optional.requirements.txt`；仅选 Python 评分方法时需要，普通 R 分支不因此增加 Python 要求 |
| 已有 R 复用分支 | R 4.5.x 与 Bioconductor 3.21 的独立 Wiki 库；旧机主要为 R 4.5.0 |
| scop 上游完整环境 | `source-rules/scop-upstream-renv.lock` 记录 R 4.5.3/Bioconductor 3.22，作为另一套来源环境保存，未在本机恢复或验证；不要混入 3.21 库 |

旧 SCP 原 `3.11-1` 标签实际声明 `python = "3.10"`，且部分旧准备逻辑拒绝 Python >=3.10。本目录原样保留这类矛盾；默认不选择该标签，也不修改原算法。scop 的部分后端要求独立模块环境，版本表只供选型。

SCP 安装目标固定为归档源码对应的 0.5.6 提交。CellChat 选择 v1/v2 仓库，保留原调用接口；不会自动换到 Spatial CellChat v3。GitHub 包已核对 DESCRIPTION 中的包名，并记录固定提交。CRAN/Bioconductor 条目是查询时版本快照；本目录没有声称它们组成了已经求解通过的锁文件。

## R：一条命令处理整批

以下命令在目标电脑运行。先修改盘符和解释器路径。`--install` 表示执行已选整批，不逐包提问；默认不带它时只检查安装存在性。所有安装均指定独立 Wiki 库，不使用系统库作为默认安装目标。

```powershell
$repo = 'E:\research-wiki'
$envRoot = 'E:\research-wiki-env'
$rs = 'D:\R-4.5.0\bin\Rscript.exe'
New-Item -ItemType Directory -Force "$envRoot\tmp" | Out-Null
$env:TEMP = $env:TMP = "$envRoot\tmp"
& $rs --vanilla "$repo\依赖清单\R\install-batch.R" --lib "$envRoot\R-lib-4.5-3.21" --profile runtime --install --report "$envRoot\dependency-reports"
```

只准备迁移待运行分支时，把 `runtime` 改为 `pending`；要连归档候选一起尝试时改为 `all`。安装器统一准备 BiocManager/remotes，按来源安装仓库包、官方归档包和 GitHub 固定提交，并在最后输出完整缺项/来源不一致报告。首次安装可能需要 Rtools45；编译失败会集中写入报告。

`ggcor` 现已定位到配方 228 随附的原始 0.9.4.3 源码归档；固定 FigureYa 提交中的归档与仓库保存字节一致，来源和 SHA256 已登记到 `repository-snapshot.json`。本轮安装该归档并实际跑通配方，没有改用其他包。其余 L0 未解析候选仍见 `R/unresolved.tsv`。

本轮经作者批准的兼容配置彼此隔离：配方 153 使用 dplyr 1.1.4，配方 61 使用 GSVA 1.48.3；后者在 R 4.5/Bioconductor 3.21 依赖上完成了功能复跑，不是旧 Bioconductor 全环境的精确恢复。RNA velocity 从旧 SCP 环境克隆副本，仅将 NumPy 1.24.4 改为 1.23.5；其余包版本逐项比对不变。完整版本和比较边界随审查记录保存。

`R-<profile>.tsv` 中 `present` 仅表示安装存在性；GitHub/归档包另检查固定来源或版本。命名空间加载、接口兼容和算法验证仍应逐分支完成。返回码 2 表示整批处理后仍有缺项、来源不一致或安装异常，可一次性处理报告；不要把它改写为验证通过。

## Python 与前端：按环境整批安装

在已准备好真实 Python 3.12 和 conda 的目标电脑运行。`$py`、`$conda` 按实机修改；这些命令不会逐包操作。网络与轮子兼容性由目标机上的 pip 解析并输出结果。

```powershell
$repo = 'E:\research-wiki'
$envRoot = 'E:\research-wiki-env'
$py = 'D:\anaconda\python.exe'
$conda = 'D:\anaconda\Scripts\conda.exe'
New-Item -ItemType Directory -Force "$envRoot\tmp" | Out-Null
$env:TEMP = $env:TMP = "$envRoot\tmp"
$env:PIP_CACHE_DIR = "$envRoot\pip-cache"
$env:CONDA_PKGS_DIRS = "$envRoot\conda-pkgs"
$env:npm_config_cache = "$envRoot\npm-cache"
& $py -X utf8 -m venv "$envRoot\wiki-python"
& "$envRoot\wiki-python\Scripts\python.exe" -X utf8 -m pip install -r "$repo\依赖清单\python\wiki.requirements.lock.txt"
& $py -X utf8 -m venv "$envRoot\ml-python"
& "$envRoot\ml-python\Scripts\python.exe" -X utf8 -m pip install -r "$repo\依赖清单\python\ml.requirements.txt"
& $conda create --prefix "$envRoot\scp-legacy" python=3.8 pip -y
& $conda run --prefix "$envRoot\scp-legacy" python -m pip install -r "$repo\依赖清单\python\scp-legacy-3.8-2.requirements.txt"
npm ci --prefix "$repo\开发\frontend"
npm run build --prefix "$repo\开发\frontend"
```

安装结束后对各 Python 环境统一运行 `python -m pip check` 并保存 `python -m pip freeze`。原来没有指定版本的 ML/现代单细胞清单只声明直接需求；解析失败需按环境整体处理，不要把旧 SCP 的固定版本强行放进界面环境。

然后按 [Windows 迁移说明](../文档/Windows迁移与验证-20261102.md) 生成本机配置，把新 R 库写入 `config.r_libs`；需要 ML 的 `python_exe` 指向 ML 环境，界面启动仍用 Wiki Python。旧 SCP 的 reticulate 绑定旧 SCP Python；同一 R 进程绑定解释器后不要临时切换另一套后端，分进程验证。这里不传输私有课题数据。

## 后续更新

完成双仓库下载并准备 Wiki Python 后，用该专用环境的真实解释器加 `-X utf8 tools/export-dependencies.py` 重新汇总声明，避免使用 Windows 商店占位命令。生成器只读取元数据，不导入科学计算包，不安装依赖，不执行源码。新增包如果不在已核查仓库快照中，会进入来源待核查清单。Python 源环境配置与上游锁文件变更时，应重新核对对应来源快照。

## 官方安装依据

- [Bioconductor 3.21 与 R 4.5](https://www.bioconductor.org/news/bioc_3_21_release/)、[BiocManager 安装行为](https://bioconductor.github.io/BiocManager/reference/install.html)
- [Rtools45](https://cran.r-project.org/bin/windows/Rtools/rtools45/rtools.html)、[pip requirements](https://pip.pypa.io/en/stable/user_guide/#requirements-files)
- [SCP](https://github.com/zhanghao-njmu/SCP)、[irGSEA](https://github.com/chuiqin/irGSEA)、[Monocle3](https://cole-trapnell-lab.github.io/monocle3/docs/installation/)、[CellChat v1/v2](https://github.com/jinworks/CellChat)

仓库元数据查询使用 CRAN 和 Bioconductor 3.21 的公开索引；Bioconductor 主站索引返回 403 时使用 Posit 镜像读取同一发行版的索引。该查询没有安装包，也没有据此宣称新机兼容性已通过。
