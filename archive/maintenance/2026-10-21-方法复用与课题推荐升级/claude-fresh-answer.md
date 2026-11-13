已按只读方式核对：`SKILL.md`、知识库 `AGENTS.md`、本课题 `README.md`、`wiki-use/fixture-run/context.json`、`mapping.json`、`data/observed-predicted.csv`、`analysis/` 输出、`wiki-candidates.json`，以及候选涉及的 Wiki 页面。未执行分析、未写文件。以下结论均以“软件夹具”为前提，不代表真实训练或科学有效性。

## 1）下一步还能做什么分析

现有材料：6 个样本 × 2 个模型 × 3 折 × 1 次重复，共 12 行；`design=kfold`，样本跨模型一致，逐样本预测齐全，但没有模型文件、特征矩阵或 SHAP 值。

**当前可做（在 `methods/regression-resampling-evaluation.md` 的已确认范围内）**

| 可做项 | 依据 | 说明 |
|---|---|---|
| 复核逐折指标 | `analysis/regression-fold-metrics.csv` | 已有输出文件，但 `context.json` 的 `completed` 只登记了预测表，未登记这次运行；按规则应补命令、环境、输入/输出哈希与检查记录，不能仅凭文件存在就称“已验收” |
| 全 OOF 汇总指标 | 方法页“怎么做”第 6–7 步 | 把每个模型的全部折外预测合并算 RMSE/MAE/R²，并与逐折指标的算术平均并列；两者通常不相等，图注必须写清 |
| 配对描述性比较 | 方法页“适用”：多模型在相同验证划分上比较 | 同一样本/折上比较两模型残差与逐折 ΔRMSE/ΔMAE；只作描述，不做显著性检验 |
| 残差与偏差描述 | 方法页“怎么做”第 7 步 | 检查是否存在恒定偏移、随预测值变化的偏差；1:1 线只在同一结局、同一量纲时使用 |
| 完整性/前提检查 | 脚本的 `EXPECTED_IDS` 与内置校验 | 可用 S1–S6 复核每折全覆盖、同折样本一致、`y_true` 一致、重复/折为正整数 |
| 整理绘图输入表 | `interfaces/regression-predictions`、`regression-fold-metrics` | 可整理 fig03 所需 points/histograms、fig04 所需 points/summaries，但模板尚未就绪，不能 render |

夹具中 model_a 是恒定 +0.5 偏移、model_b 是恒定 +1.0 偏移；每折只有 2 个样本， Pearson r 由两点必然接近 ±1，不能解释为“预测很好”。逐折 R² 的算术平均也会明显低于全 OOF 汇总 R²，这正是应并列报告的原因。

**少量补材料候选**

- 多次重复或重复 K 折（`repeat≥2`）：才能谈划分敏感性；现在每模型只有 3 个折点，箱线分布意义很弱。
- 训练折均值/临床基线预测：才能判断 RMSE/MAE 是否优于简单基线；当前表没有基线。
- 锁定外部测试集：才能谈外部泛化；当前没有。
- 受试者/中心/时间字段与划分清单：若存在重复测量或时间依赖，需改用 GroupKFold/时间划分；当前只有 `subject`，不足以判断。
- 已训练模型、特征矩阵、背景/解释样本：SHAP 的前置材料；当前全部缺失。
- 校准、预测区间、模型间显著性检验：库存没有对应 ready 方法，须先说明方案并询问作者，不能自动补算法。

## 2）已有预测/指标适合什么可视化，能否现在调用库存模板

| 图样 | 页面 | 适合的数据 | 当前状态 | 现在能否调用 |
|---|---|---|---|---|
| 密度散点＋边缘分布＋1:1 线 | `layouts/2026-10-19-regression-stability__fig03-density-panel.md` | 逐样本 observed/predicted；看偏差、分布、相关性 | `pending_template`，`templates: []`，来源为估读 RGB/直方表 | **不能**；没有 ready 模板，估读表也不能直接接真实预测 |
| 箱线散点＋均值 | `layouts/2026-10-19-regression-stability__fig04-boxplot-panel.md` | 逐折指标按模型比较一个指标分布 | `pending_template`，`templates: []`，需要 points 与 summaries 同源一致 | **不能**；且每模型仅 3 折，箱线很弱，建议先补重复 |
| SHAP 条形图/环形图 | `templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar.md`、`--radial-bar.md` | `shap-summary.csv` | 模板 `ready`，但本课题无 SHAP 表 | **不能**；数据接口不满足 |
| SHAP 蜂群图 | `templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm.md` | `shap-samples.csv` | 模板 `ready`，但本课题无 SHAP 表 | **不能**；数据接口不满足 |

结论：**现在不能调用任何库存模板出这两类图**。fig03/fig04 只是已签核的图样来源，不是可调用模板；SHAP 模板虽 ready，但与当前预测表无接口关系。若用画廊估读数据做“画法示例”，只能明确标为合成/估读示意，不能当作本课题结果。另需注意：SHAP 三个模板是历史固定尺寸实现，任意 n、长标签和配色尚未迁移为自适应模板。

## 3）observed/predicted 等列与 Wiki 输入不同，具体如何处理

按“课题副本仅改列名、不改统计与行”的方式处理，原表不动。现有 `wiki-use/fixture-run/mapping.json` 已记录：

| 原列 | Wiki 列 |
|---|---|
| `subject` | `sample_id` |
| `algorithm` | `model` |
| `repetition` | `repeat` |
| `validation_fold` | `fold` |
| `observed` | `y_true` |
| `predicted` | `y_pred` |
| `design` | `split_design` |

执行要求：

- 只生成 `analysis/regression-predictions.csv` 副本，保留 `data/observed-predicted.csv` 原表；不聚合、不填补、不换算单位、不改行数。
- 核对语义而不只是列名：一行必须是“样本×模型×重复×验证折”；同一 `sample_id` 的 `y_true` 跨模型一致；各模型共享同一折成员；`split_design` 只能有一个值且属于允许集合。
- 记录映射、源文件哈希、代码哈希与检查结果；`mapping.json` 已声明 `source_unchanged`、`values_roundtrip`、`long_wide_roundtrip`、`missing_values_preserved` 为 true，本轮只读未重算哈希。
- `wiki-candidates.json` 中“列覆盖 无；缺少 sample_id…”是按原始列名检查的结果，**不能据此排除**；完成映射并核对语义后才判断可接。
- 若出现同名异义（例如 `predicted` 实际是概率、`observed` 是 log 变换后的值），不能按列名硬映射，必须停下来询问。
- 即使列映射成功，也只证明接口结构满足；`context.json` 明确没有真实模型/训练证据，不能据此声称模型训练或验证通过。

## 4）假如 observed 和 predicted 的单位/定义没有说明，应如何处理

当前夹具明确写了“同一结局、同一量纲”，所以本轮可以做上述描述性汇总。若这个前提被移除，按以下顺序处理：

1. **停止执行指标与 1:1 图**：单位/定义不明时，RMSE、MAE、R²、r 的数值含义不成立，1:1 线也不成立。
2. **向作者逐项确认**：是否为同一结局、同一单位/尺度、同一变换（原始值/log/标准化）、同一时间点与人群；`predicted` 是否为未使用该验证样本训练的折外预测；一行是否为一个独立样本，是否存在重复测量。
3. **不自行推断**：不从数值范围猜单位，不做单位换算、标准化反变换、聚合、删行、填补或重算统计量。
4. **只做安全的结构检查**：ID、折号、重复号、重复行、覆盖率和缺失值可以检查；不比较模型优劣。
5. **记录未知项**：在课题 `wiki-use/<本次标识>/context.json` 写明未知字段与待确认问题；确认后再补 mapping 和单位说明。
6. 若作者只想要“先看一眼分布”，也只能分轴、明确标注“单位未知”，不使用 1:1 线，不把两模型放同一量纲上排名。

## 5）来源 XGBoost＋SHAP 能推广到哪里、代码和验证范围如何确认

**推广边界**（见 `methods/shap-explanation.md`“原始实现与家族范围”“适用/不适用”）：

- 可推广的核心是“明确模型输出 → 选择适用解释器/背景 → 计算归因 → 整理成 `shap-summary`/`shap-samples`”，不是“任意模型都能用同一入口”。
- 树模型分支：官方 TreeExplainer 支持其列出的树模型家族；线性分支用 LinearExplainer；其他预测函数用 Explainer，需核对 masker、算法和计算成本。
- 不能直接推广到多分类、多输出、时序/分组划分、任意原生类别特征；这些需另核接口与实现。
- 解释的是既定模型的行为，不等于因果、预测校准、外部验证或临床有效性；相关特征和背景选择必须说明。
- 当前项目没有模型、特征和背景样本，**不能执行 SHAP**；只能把它作为“补材料后”的候选。

**代码与验证范围确认方式**：

- 页面：`methods/shap-explanation.md`；原始片段在 `methods/shap-explanation/source/`，复用版在 `methods/shap-explanation/code/shap_explain.py`，清单为 `source/manifest.json`、`code-manifest.json`。
- 先区分“原始归档”和“复用改造版”：原始片段标为 `example_not_target`，是只读示例/片段，不是原帖目标整图的完整实现；复用版是后来整理的独立脚本，不是原作者原件。
- 复用脚本会自己读取 `data.csv`、随机划分并训练（`TEST_SIZE=0.3`、`RANDOM_STATE=42`），不是接入任意已拟合模型的纯函数；若课题已有既定划分/模型，需改造而不是直接运行。
- 方法页已记录静态核查问题：部分线性分支传入 `random_state`、不同分类解释器输出尺度等仍需逐分支复核；旧“四类模型实测”表没有配套日志，不能沿用为验证证明。复用代码的验证状态是 `not_run`。
- 三个模板的关系是 `direct`（表契约直接对应），但关系验证也是 `not_run`；`direct` 只表示不需要改列名/整形，不证明上游训练、解释器分支或输出尺度正确。
- 实际确认应在课题自己的 Python/R 环境：核对源码 SHA-256、解释器/模型版本、解释的是哪份输出、背景与解释样本、特征顺序、输出尺度；与原实现做数值对照；记录命令、环境和结果到课题 `wiki-use/`。不要用知识库环境代跑，也不要擅自安装包。

## 6）一段当前课题映射成功后要不要自动写回 Wiki

**不要自动写回。**

- 按 `SKILL.md` 和 `AGENTS.md`：项目映射先留在课题，记录在 `<课题>/wiki-use/<本次标识>/`（本课题即 `wiki-use/fixture-run/context.json`、`mapping.json`）；只有具备通用价值时，才提出“回存内容＋证据”，由作者再次确认后入库。
- 不能覆盖原版、不能污染全库接口，也不能把一次夹具映射成功当成通用规律。
- 本轮全部数据是合成夹具，映射成功只说明软件路径可走通，不构成真实课题证据，更不应写入正式 Wiki。
- 只有实际完成“方法→出图”并需要登记使用时，才用 `record-use` 记录模板、课题、输出路径和方法；这与“回存映射”是两件事。
- 若以后发现某种列名别名/映射模式反复出现且有通用价值，应先在课题记录中整理证据，再向作者提出具体回存内容和影响范围，等确认后再改 Wiki。

本轮仅完成只读核对，未写文件、未运行分析；上文涉及的数值只是夹具表的算术特征，不是训练或科学有效性证据。