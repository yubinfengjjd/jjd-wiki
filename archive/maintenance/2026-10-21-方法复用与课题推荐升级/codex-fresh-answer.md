已只读核对候选页；README/context 回显截断，课题定义未完整核验。以下仅为软件夹具建议，不构成训练或科学有效性证据。页面路径相对 Wiki 根。

1）当前可做候选：`methods/regression-resampling-evaluation.md`，用于已有验证预测的逐折 MAE、RMSE、R²及稳定性比较；前提是同量纲、样本配对、预测来自折外且划分明确。复用代码状态为 `example`，仅有历史合成表指标/校验记录，不含训练或课题联调。

2）预测适合观测—预测散点及边缘分布，指标适合箱线＋散点。页面为 `layouts/2026-10-19-regression-stability__fig03-density-panel.md`及同前缀的`fig04-boxplot-panel.md`。两者均为待模板化图样，关系为 adaptable、验证 not_run；现在不能直接调用。密度、箱线摘要算法仍须明确，不能照搬来源颜色或摘要。

3）语义确认后，仅在未来获准的课题副本映射：subject→sample_id、algorithm→model、repetition→repeat、validation_fold→fold、observed→y_true、predicted→y_pred、design→split_design。检查类型、粒度、配对并记录映射，保留原表；不自动聚合、填补或换算。

4）单位/定义不明时暂停执行并询问，不能凭列名猜测或先算再解释。

5）补材料候选：`methods/shap-explanation.md`，解释模型贡献；需模型、特征处理、背景及解释样本，现有预测表不足。XGBoost＋SHAP可有条件推广到适配解释器的模型；库存脚本并非任意已拟合模型接口，多分类等未覆盖。代码 not_run；SHAP模板虽 ready、关系 direct，也仅核对契约，未联调；归因不证明因果或临床效用。

6）映射成功后留在课题；有通用价值且作者再次确认后才回存 Wiki，本次不写回。