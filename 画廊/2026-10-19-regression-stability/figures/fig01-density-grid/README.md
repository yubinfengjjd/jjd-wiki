# 六模型预测密度散点（含边缘直方图）

来源：[Python机器学习AI，2026-10-19](https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg)。原文位于帖子根目录 source.md / article.html；原图只读保存在 source/。作者本轮选择只复刻两张组图，不另建单图条目。

## 来源与状态

- status=review（已渲染并完成机械检查，等待作者目视签核）；仅作者签核后才可 approved。
- code_provenance=reconstructed：code/replica.py 为本次新写代码。original_code_provenance=archived_only：7段原帖代码按序与原语言标签归档，SHA-256 见 original_code/manifest.json，全部未执行。
- 缺少原始Excel、两个绘图函数、折外预测生成和六模型评估代码；没有训练模型，没有恢复原始观测。
- data_provenance=estimated。散点坐标、颜色和直方图高度来自原图线性像素估读，遮挡点不能逐样本恢复。箱线图数据、箱体和均值菱形是独立视觉估读；横向抖动为固定种子合成。
- 所有数据仅供图形复刻，不能作为原始样本、折指标或统计推断。注释照录原图的舍入数值，不是根据估读点重新计算的结果。图形中原有 Frequency 色标保留，原始归一化未知，不能据其解释实际频数。

## 适用

连续结局回归任务，展示同一验证设计下多模型的预测一致性及逐折误差分布。真实课题应输入真实折外/留出预测和指标，详见知识库方法 regression-resampling-evaluation。

## 不适用

分类或生存结局、直接证明临床效用/外部泛化、把相关折作为独立实验、根据这些估读数据做显著性检验；没有验证预测时不能将训练回代图称为 OOF。

## 运行

专用 Python：C:/Users/86186/.codex/venvs/sci-figure-replica/Scripts/python.exe。运行 `python -X utf8 code/replica.py`（实际调用须使用前述绝对解释器）。参数、轴校准、图框、原图标注及数据分类位于 data/figure_spec.json；CSV 可审阅。

输出为 output/replica.png（600 dpi）、PDF、SVG，compare/side_by_side.png 为等高并排；运行命令和退出码见 run.log，版本/字体见 stdout.txt。制图使用 Arial，源字体文件未知。

## 关键限制

估读误差、点遮挡和合成抖动使本次只能作视觉近似。箱体统计与点读数分别保存，不能冒称精确恢复一致的10折数据。源图无 A-F / A-C 字母，元数据仅为面板路由分配逻辑编号；复刻不添加新字母。独立PDF/SVG视觉检查范围见 qa_report.md。未获得作者签核。
