# G3 当前可验收范围盘点

2026-10-25 Codex只读检查正式方法库。证据：domain-implementation-inventory-current.json。

- 正式 analysis 家族15个，12个有 runtime.json。按实际标签盘点，除单细胞标签之外的两个条目是 regression-resampling-evaluation 和 shap-explanation，均属于机器学习，当前均缺 runtime.json。
- 这两条分别有 summarize-predictions 和 shap-explain-model 代码与各自收据，但不能据此声称本轮满足“按清单复制最小闭包、独立迁移”的执行条件，更不能把二者计为两个不同领域。
- G3“两个非单细胞领域，至少一个原生非表对象”的真实分支验收目前存在库存/运行契约缺口。领域配置及结构fixture通过不能填补这个缺口。不能为了凑覆盖新写算法、补装依赖或将单细胞成图借给其他领域。
- 这不是否定跨领域内核；内核、状态/证据、运行条件和真实算法覆盖分开验收。本次最终矩阵必须保留G3 partial/not_run及原因，不报告全领域算法已支持。

后续可先为已有ML分支补齐有依据的运行契约并独立验证，再由作者选择第二领域的真实材料/来源。该建议不是本次授权安装、下载数据或自动扩库。
