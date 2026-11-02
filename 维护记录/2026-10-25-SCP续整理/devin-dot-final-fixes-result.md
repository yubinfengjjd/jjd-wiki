收到，两项具体修复。先确认 fixture、RED 日志与当前文件状态。确认两问题属实。先修两个 reader：render.R 与画廊 replica.R 用 `colClasses` 显式字符解析键列、`na.strings=character(0)` 保字面 NA。跑 fixture 渲染并验证 identity 保留前导零。输出可疑，直接检查 b 结构。写临时检查脚本避免转义问题。Identity 保留确认。重渲染 fixed-1m 与画廊双入口，确认仍字节一致。`colClasses="numeric"` 撞上带引号数值会失败。收窄为只强制三个 identity 列，其余走正常猜测。全部一致。复查 identity 检查仍过（colClasses 收窄后）。新闭包哈希 + 更新回执。最小化更新各文档（闭包哈希/portable-r4/reader/excerpt）。收尾：画廊 README/run.log、runtime-facts 刷新、check-entry、lint、save。两项修复完成，全部实跑证据落地。

## Round-3 结果

**1. CLI 输入契约** — `render.R` 与画廊 `replica.R` 对 `matrix`/`feature`/`group` 显式 `colClasses="character"` + `na.strings=character(0)`：

- Codex fixture（`001`/`01`–`05`）→ 真实 PNG/PDF/SVG 输出（`9DCD07C7…`），dimnames 保留 `001`/`01`（`check_numeric_ids.R` → IDENTITY-PRESERVED OK）
- 字面 `"NA"` 保字符串、空单元格仍拒绝、多余列容忍猜测；首轮宽 colClasses 撞引号数值已收窄为仅三身份列
- 直接函数类型规则未动

**2. original_code 字节** — 旧注释版存 `evidence/groupheatmap-dot/history/`；重取固定源 7911–9036 行**含 CRLF 行尾**字节切片（54168 B，`1497d20d…`），`provenance.json` 更新，全文件 SHA 未动，未触 fig08。

**一致性**：画廊 code 同步、两入口重跑 `7CC121E7`/`1803D5FC` 字节一致；portable-r4 异目录新进程字节一致；官方 `runtime_facts`→`verified`（closure `c474e19d…`）；fixed-1m 固定对照仍字节相同；lint `OK`、check-entry passed、ht1 baseline 收据链未动、方法页验收已 --record。gallery `draft`、layout `pending_signoff`、无正式模板。

## 剩余限制（如实）

- digit-like fixture 只有模块输出，无原生对照——它证明输入处理非视觉保真
- PDF 仍未做结构比较；reticle SVG 未对照
- 共享会话副作用仅如实声明，隔离仍靠 CLI 新进程
- 作者签核与终审仍待进行