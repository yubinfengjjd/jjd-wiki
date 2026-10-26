# Codex 独立审查结论（2026-10-23）

结论：两轮必修项已关闭，允许按已授权计划部署。未代替作者确认页面/科学适用性；13 个方法家族仍待作者正常确认。

## 已关闭的问题

- 分类 query 从 hash 路径中分离；独立浏览器验证领域→用途、搜索用途名、清空、切换领域重置、刷新保留与打开方法详情，当前均通过。
- Python 适配全表预检来源/输出碰撞，写前源哈希、暂存后提交及失败恢复；R 移开旧目录项并重命名暂存文件，不写穿硬链接源。独立强制无 fs 复现原表已不变，重复调用成功。
- R/Python 对包含同名回退的有效映射检查重复消费；缺少必需语义不能由同一来源列悄悄填补。
- R pivot 不再拼接/拆分主键；空字符串、嵌入 CR 等值保真；重复键拒绝。
- R 独立调用报告 semantics 非空，明确不验证单位、粒度、配对，不自动换算。

## 独立验收证据

维护记录：`E:/research-wiki/维护记录/2026-10-23-分类与灵活输入/`。

- `logs/codex-pytest-review1.log`：正确加载既有运行环境后，全套 **489 passed / 2 skipped**。后续仅 R helper 及一个对应测试发生变化，`logs/codex-binding-review2.log` **71 passed**（绑定与 spec）。Claude 自测最终全套490/2仅作补充，不混同独立运行结果。
- `logs/codex-frontend-test.log`、`codex-frontend-typecheck.log`：前端24项方法检查、30项图库检查及类型检查通过。前端构建产物已检查，第二轮未再改前端。
- `codex-browser-review.json`、`browser-route-after.txt`、`codex-browser-classification.png`：独立真实浏览器点击，领域/用途/计数/URL/搜索/清除/刷新/详情通过。
- `codex-real-validation/summary.json`：独立重新运行3个真实R/Python模板的5个绑定场景及1个缺必需项负例；四个场景像素MAD=0，点图省略target_group使用原有排序回退（MAD=8.005185978），没有数值转换；缺必需项拒绝且无图。标准example与外部author输入前后哈希保持。
- 独立 `codex-review-repeat.R`：semantics非空，重复调用成功；`codex-review-nofs.R`：强制无fs，输出正确且source_changed=FALSE。
- `codex-integrity.json`：210个原始源码文件哈希保持，78页旧id/status/favorite/archived_from/user区块未变；正式/staged AGENTS逐字节相同。
- 正式库lint无ERROR，仅5个既有not_run分支警告；原始失败日志保留。初次独立全套的单个R失败来自未加载运行环境，之后正确环境下通过。独立绘图验收脚本曾因报告键名改动发生KeyError，已修复检查脚本并对已生成全部结果核验通过，未修改产品或原始数据来绕过。

## 范围与限制

- 单模板render支持bindings；render-layout组合仍使用标准表。真实案例覆盖可选列，可选表只有软件夹具证据。
- R无openssl时SHA256字段为NA，CLI仍记录SHA256。无fs不提前识别所有硬链接，但替换方式已验证不写原inode。
- 分类只用于发现；具体实现依赖、当前验证收据、not_run与作者确认独立。未安装依赖，未改变分析/统计算法，未声称真实课题或科学有效性已验证。
- Markdown、原始来源只读、编译知识、规则、索引/日志分工保持；来源panel仍在画廊，Wiki只保存引用与证据。skill八步入库已加入语义去重、领域/用途、显式映射、可选依据及验证边界。

下一步：备份并同步五处安装、逐文件SHA256核验，精确重启8765正式服务并检查API与部署版界面；完成后另写final-acceptance.md。
