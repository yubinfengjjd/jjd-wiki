# Codex 独立审查第一轮（2026-10-23）

结论：暂不通过，不部署。Claude 已结束（exit 0），报告到可审查状态；报告与测试通过不能代替路由或数据完整性验收。请重新阅读 implementation-plan.md 与本文件，用原会话修复，不启动子代理、不安装依赖。

## 必修项

1. **P1 分类入口在真实路由不可用。** `methods.ts` 生成 `#/methods?domain=...&purpose=...`，但 `route.ts` 仍把整个 `methods?domain=...` 当 view；App 只比较 `route.view === 'methods'`，点击领域/用途/搜索全部跳到图库。SSR 直接传 query 绕过了这个问题。修复 hash 路由解析与 query 传递，保留 page/其他旧路由，不对 query 先整段 decode 导致 `%26`、`%2F` 等含义改变。加入真实 route→App/MethodsView 路径回归；必须用浏览器点击验证分类、搜索、清空、刷新保留。搜索框 defaultValue 可能在清除/URL变化后仍显示旧值，也需核对。搜索宣称支持用途但 filterAnalysisMethods haystack 不含 purposes，应补上。

2. **P1 可复制适配器覆盖原始输入并伪记源哈希。** 独立夹具：`values.csv` 内容 `n\r\n2\r\n`，spec interface=values，mapping value→n，调用 `prepare_tables(spec, bindings, data_root=root, work_dir=root)`。源文件被改写为规范表，report.source_sha256 是改写后哈希。R prepare_binding_table 同样无碰撞保护。修复 R/Python：写前预检所有来源与全部输出路径，禁止输出覆盖任一源文件（同名、别名/链接、另一个表输入等）；哈希在写前采集，失败不应留下部分规范输出。不要只修 CLI：CLI 本就用了临时目录，问题是承诺可复制的独立 helper。原始数据不变是本计划硬约束。测试只用临时夹具。

3. **P2 显式映射和隐式同名回退可以复用同一个源列、掩盖必需语义缺口。** Python/R 都复现：columns={group,feature}，源只有 feature=CD3，mapping={group:feature}，结果 group=CD3、feature=CD3，缺失 group 没报错。现有重复映射检查只查显式 mapping 值。核对完整 effective mapping（显式+同名回退），同一源列多消费需拒绝，报告具体冲突，不猜测或补造必需字段。加 R/Python 同夹具负例。

4. **P2 R pivot 悄悄改主键。** `.reshape_binding` 用 `\r` 拼接/拆分 index：a=`x\ry`, b=`z` 经 pivot 变成 a=`x`, b=`y`，z丢失；空字符串 id 变 NA。Python tuple 版本不会。修复 R 使用无碰撞的键标识，输出 index 从原行取值，不从分隔字符串还原。覆盖多列、嵌入分隔符、空字符串、缺失值、重复键，比较 R/Python 不改值；如不支持某值则显式拒绝，不能静默改值。R 文件路径检查也应使用路径分量边界和规范化路径，不能只用 startsWith(source, root)。

复现脚本见维护记录 scripts/codex-review-probes.py 和 .R。R 用 E:/research-wiki-env/work/scp-runtime.ps1 的进程环境执行。

## 证据质量

`validate_bindings.py` 当前 source_sha256 与 input_sha256_after 都在 render 之后算，且指标准 example，不是真正外部输入。请在调用前后分别记录 example 和 author/my_data.csv 哈希；不覆盖旧报告，修复后的报告存新文件。R/Python 转换等价、原始输入保持必须真实断言。

修复仅上述范围及必要测试/文档；更新 claude-result.md、verification-matrix.md，原失败证据保留。先运行定向，再必要全套，禁止无改动反复跑全套。仍停在审查版本，不部署、不重启正式服务、不提交开发仓库。Codex 独立检查通过才部署。
