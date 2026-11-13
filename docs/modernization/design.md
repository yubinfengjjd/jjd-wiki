# 检索与目录改造设计

## 知识与查询

Markdown 与原始资产仍为知识本体。派生全文索引放在本机 work_root，按章节构建 BM25，合并为页面结果；默认检索知识，源码为显式范围。可执行资格不写死在全文索引里，返回时核对当前记录。

接口：rwiki find 保留旧选项并增加 --scope；GET /api/search 返回 results、coverage、index；静态导出与浏览器共用语料及排名规范。新增资产状态 available、not_downloaded、missing，与科学验证状态分开。

## 按需获取

轻量方式采用 Git partial clone 与 sparse checkout，保留知识页、必要声明和缩略图。只有 assets fetch、use 或网页显式 POST 才补齐条目资产。当前机器保持完整检出。轻量方式阻止正式 Wiki 写入，checkout --profile full 可切换完整方式。

## 路径与迁移

主库：wiki、gallery、docs、tools、integrations/obsidian、archive/docs、archive/maintenance。

开发库：skills/research-wiki、apps/web、plugins/obsidian-neural-view、docs、tests/e2e、examples/replications、tools、ci、archive。

代码集中识别新旧布局；先提供兼容解析再迁移。实际本机嵌套开发检出根保持不变，新下载使用同级两库。迁移清单记录原路径、目标路径、文件哈希、配置备份及兼容联接；回退前核对修改，拒绝覆盖。保留 Git 历史，不以迁移刷新科学收据。
