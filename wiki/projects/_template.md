---
type: project
slug: _template
title: 课题步进记录卡模板
playbook: scrna-stepwise-playbook
status: draft
templates: []
methods: []
summary: 新建科研课题的极简 3 行式步进追踪卡模板，记录每一步所用模版、观察现象与触发的下一步决策方向。
---
# 课题步进记录卡模板

> 复制本模板为 `<YYYY>-<课题短名>.md`（或通过 `rwiki project add-step` / Web 课题步进看板自动追加），每完成一步只记录最关键的 3 行决策证据。

## 课题概览

- **研究问题**：待填写（例：某疾病单细胞 × Bulk 联合挖掘关键亚群与标志物）
- **所属决策树**：[[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树]]
- **本地课题目录**：`<课题目录路径（数据与成图不入 Wiki）>`

## 步进记录

### Step 1：示例步骤标题（替换为当前分析阶段）

- **【所用模版】**：`methods/<method_id>` + `templates/<template_id>`（或 `recipes/<recipe_id>`）
- **【观察结果与排坑】**：记录关键量化指标、异常发现、参数调整或排坑细节（如线粒体阈值、批次去重情况）。
- **【触发下一步】**：说明基于上述观察选择了哪条下游分支及原因（例如：`方向 3 -> gene-set-scoring`）。
